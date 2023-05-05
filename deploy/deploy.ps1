Write-Host "请先准备好下面条件："
Write-Host "1. 一个 Azure 订阅"
Write-Host "2. Docker Desktop for Windows"
Write-Host "3. Azure CLI"
#按任意键继续
$continue = Read-Host -Prompt "继续吗？(yes/no)"
#如果 $useExistingAcr 等于 "yes" 或 "y"，则继续


if ($continue -ieq "yes" -or $continue -ieq "y") {
   
} else {
    Write-Host "请先准备好"
   exit
}

# Login to Azure
az login

# Set default subscription
# az account set --subscription "your-subscription-id"
az account show

$continue = Read-Host -Prompt "这是正确的订阅吗？(yes/no)"

# Define ACR info
if ($continue -ieq "yes" -or $continue -ieq "y") {
   
} else {
    Write-Host "请先登录到正确的订阅"
   exit
}

# Set default location and resource group
$location = "eastasia"
$resourceGroupName = "rgOpenAIChat"
# az configure --defaults location=$location group=$resourceGroupName

# Create resource group if not exists
Write-Host "创建资源组 $resourceGroupName ..."
az group create --name $resourceGroupName --location $location

# Check if user wants to create a new ACR or use an existing one
$useExistingAcr = Read-Host -Prompt "使用现有的ACR(Azure 容器注册库) 吗? (yes/no)"

# Define ACR info
if ($useExistingAcr -ieq "yes" -or $useExistingAcr -ieq "y") {
    $acrName = Read-Host -Prompt "请输入现有的ACR名称"
    $acrLoginServer = az acr show --name $acrName --query 'loginServer' -o tsv
} else {
    $acrName = Read-Host -Prompt "请输入新建的ACR的名字(需全球唯一)"
    Write-Host "创建ACR..."
    az acr create --name $acrName --sku Basic --location $location --resource-group $resourceGroupName
    $acrLoginServer = az acr show --name $acrName --query 'loginServer' -o tsv
}

# Push docker image to ACR
$dockerImageName = "vuegpt"
$dockerTagName = $acrLoginServer + "/"+ $dockerImageName + ":basic.stream"
Write-Host "开始建Docker Image..."
docker build -t $dockerTagName ..
# docker tag $dockerImageName $dockerTagName
az acr login --name $acrName
docker push $dockerTagName

# Create Azure Web App
$webAppName = Read-Host -Prompt "输入 Web App 的名字(需全球唯一)"
$planName = $resourceGroupName + "Plan"
Write-Host "创建 Web App..."
az appservice plan create --name $planName --sku B1 --location $location --resource-group $resourceGroupName --is-linux
az webapp create --name $webAppName --plan $planName --deployment-container-image-name $dockerTagName  --resource-group $resourceGroupName
az webapp config appsettings set --name $webAppName --resource-group $resourceGroupName --settings WEBSITES_ENABLE_APP_SERVICE_STORAGE="false"

az acr update -n $acrName --admin-enabled true

# Get ACR password
$acrPassword = az acr credential show --name $acrName --resource-group $resourceGroupName --query "passwords[0].value" -o tsv

# Set webapp container settings
az webapp config container set --name $webAppName --resource-group $resourceGroupName --docker-custom-image-name $dockerTagName --docker-registry-server-url "https://$acrLoginServer" --docker-registry-server-user $acrName --docker-registry-server-password $acrPassword

# Browse the Web App
az webapp browse --name $webAppName --resource-group $resourceGroupName
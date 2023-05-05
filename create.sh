docker build -t vuegpt:basic.stream .

docker run -p 8080:8080 \
  -e VUE_APP_OPENAI_API_KEY=your_openai_api_key \
  -e VUE_APP_DEPLOYMENT_ID=your_deployment_id \
  -e VUE_APP_MODEL_ID=your_model_id \
  -e VUE_APP_TITLE=your_title \
  vuegpt:basic.stream
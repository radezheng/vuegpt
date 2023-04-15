<template>
    <div class="header">欢迎使用Azure OpenAI</div>
    <div class="chat-container">
      
      <div class="chat-history" ref="chatHistory">
            <vue-showdown
                v-for="(message, index) in messages"
                :key="index"
                :markdown="'**' + message.role + '**: ' + message.content"
                flavor="github"
                extension="table,footnote"
                :class="message.role"
                ></vue-showdown>
      </div>
      <form @submit.prevent="sendMessage" class="input-container">
        <textarea v-model="inputMessage"  @keydown.enter.prevent="sendMessage" placeholder="输入你的消息..."></textarea>
        <button type="submit">发送</button>
        <button  @click="clearMessage" >Clear</button>
      </form>
      
    </div>
  </template>
  
  
  
  <script>
 import axios from "axios";
 import { VueShowdown } from 'vue-showdown';

  var apikey = process.env.VUE_APP_OPENAI_API_KEY;
  var url = 'https://' + process.env.VUE_APP_DEPLOYMENT_ID + '.openai.azure.com/openai/deployments/'+ process.env.VUE_APP_MODEL_ID +'/chat/completions?api-version=2023-03-15-preview';

  var dataground= {"role": "system", "content": "You are a helpful assistant."};

  export default {
  components: {
    VueShowdown, 
  },
    data() {
      return {
        inputMessage: "",
        messages: [],
        contextMaxLength: 5
      };
    },
    methods: {

      clearMessage() {
            this.messages = [];
        },

      sendMessage() {
        if (this.inputMessage.trim()) {
          this.messages.push({ role: "user", content: this.inputMessage });
        let msgtosend = [];
        for (let i = Math.max(0, this.messages.length - this.contextMaxLength); i < this.messages.length; i++) {
          msgtosend.push(this.messages[i]);
        }
      
        msgtosend.unshift(dataground);

        axios
            .post(url, {
              messages: this.messages,
              max_tokens: 2000,
              n: 1,
              stop: null,
              temperature: 0.9,
            },
            {
              headers: {
                'Content-Type': 'application/json',
                'api-key': `${apikey}`,
              },
            })
            .then(response => {
              this.messages.push({ role: "assistant", content: response.data.choices[0].message.content });
            })
            .catch(error => {
              console.error(error);
              if(error.response.data.error){
                this.messages.unshift({ role: "assistant", content: error.response.data.error.message });
              }
            });
  
          this.inputMessage = "";
        }
      },
    },
  };
  </script>
  
  <style scoped>
  /* @import "~github-markdown-css/github-markdown.css"; */

body {
  margin: 0px;
}
.header {
  background-color: #f5f5f5;
  padding: 10px;
  text-align: center;
  font-size: 20px;
  color: #333;
}


.chat-container {
  padding: 10px;
  align-items: center;
}

.assistant{
  background-color: rgb(228, 225, 225);
  padding: 1px;
  padding-left: 10px;

}

.user {
  padding-left: 10px;
}
.input-container {
  position: absolute;
  top: 90%;
  width:90%;
  display: flex;
  padding: 5px;
}
.input-container textarea {
  flex-grow: 1;
  height: 2rem;
  margin-right: 5px;
  width: 70%;
}

.chat-history {
  max-height: calc(100vh - 20rem);
  padding: 1.5rem 0;
  overflow-y: scroll;
}

pre {
  white-space: pre-wrap;
  word-wrap: break-word;
}
  </style>

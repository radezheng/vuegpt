<template>
  <div class="header">欢迎使用Azure OpenAI - GPT4</div>
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
    <div class="loading-spinner" v-if="loading"></div>
    <form @submit.prevent="sendMessage" class="input-container">
      <textarea
        v-model="inputMessage"
        @keydown.enter.prevent="sendMessage"
        placeholder="输入你的消息..."
      ></textarea>
      <button type="submit">发送</button>
      <button @click="clearMessage">Clear</button>
    </form>
  </div>
</template>

<script>
//  import axios from "axios";
import { VueShowdown } from "vue-showdown";

var apikey = process.env.VUE_APP_OPENAI_API_KEY;
var url =
  "https://" +
  process.env.VUE_APP_DEPLOYMENT_ID +
  ".openai.azure.com/openai/deployments/" +
  process.env.VUE_APP_MODEL_ID +
  "/chat/completions?api-version=2023-03-15-preview";

var dataground = { role: "system", content: "You are a helpful assistant." };

export default {
  components: {
    VueShowdown,
  },
  data() {
    return {
      inputMessage: "",
      messages: [],
      contextMaxLength: 5,
      loading: false,
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
        for (
          let i = Math.max(0, this.messages.length - this.contextMaxLength);
          i < this.messages.length;
          i++
        ) {
          msgtosend.push(this.messages[i]);
        }

        msgtosend.unshift(dataground);

        if (this.eventSource) {
          this.eventSource.close();
        }

        this.loading = true;
        this.streaming = false;
        this.scrollToBottom();
        const xhr = new XMLHttpRequest();
        xhr.open("POST", url, true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("api-key", apikey);
        xhr.responseType = "text";
        xhr.onreadystatechange = () => {
          if (xhr.readyState === XMLHttpRequest.LOADING) {
            let res = xhr.responseText;
            // break each lines of res to string
            let lines = res.split("\n");
            let newmsg = {};
            //for each line, remove the first 5 characters
            for (let i = 0; i < lines.length; i++) {
              if (!lines[i].startsWith("data:")) continue;

              lines[i] = lines[i].slice(5);
              
              let jline = {}
              try{
                jline = JSON.parse(lines[i]);
              }catch(err){
                console.log(err);
                console.log(lines[i]);
                continue;
              }
              jline = jline.choices[0];
              if (jline.finish_reason == "stop") break;

              if (jline.delta.role)
                newmsg = { role: jline.delta.role, content: "" };

              if (jline.delta.content) newmsg.content += jline.delta.content;
            }

            //delete last message from messages
            if (this.streaming) this.messages.pop();
            this.messages.push(newmsg);
            this.streaming = true;
          } else if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
              this.loading = false;
              this.streaming = false;
            } else {
              console.error(xhr.statusText);
              this.loading = false;
              if (xhr.response.data.error) {
                this.messages.unshift({
                  role: "assistant",
                  content: xhr.response.data.error.message,
                });
              } else {
                this.messages.push({
                  role: "assistant",
                  content: xhr.response,
                });
              }
            }
          }
          this.scrollToBottom();

        };

        xhr.send(
          JSON.stringify({
            messages: this.messages,
            max_tokens: 2000,
            n: 1,
            stop: null,
            temperature: 0.9,
            stream: true,
          })
        );

        this.inputMessage = "";
        // this.scrollToBottom();
      }
    },

    scrollToBottom() {
      const chatHistoryElement = this.$refs.chatHistory;
      chatHistoryElement.scrollTop = chatHistoryElement.scrollHeight+1000 ;
    },

  },
};
</script>

<style scoped>
/* @import "~github-markdown-css/github-markdown.css"; */

.loading-spinner {
  border: 4px solid rgba(0, 0, 0, 0.1);
  width: 20px;
  height: 20px;
  border-radius: 50%;
  border-left-color: #09f;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

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

.assistant {
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
  width: 90%;
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
  max-height: calc(100vh - 18rem);
  padding: 1.5rem 0;
  overflow-y: scroll;
}

pre {
  white-space: pre-wrap;
  word-wrap: break-word;
}
</style>

/**
 * Provides classes modeling security-relevant aspects of the `@google/genai` package.
 * See https://github.com/googleapis/js-genai
 */

private import javascript

module GoogleGenAI {
  /** Gets a reference to the `GoogleGenAI` client instance. */
  API::Node clientRef() {
    // import { GoogleGenAI } from '@google/genai'; const ai = new GoogleGenAI(...)
    result =
      API::moduleImport("@google/genai").getMember("GoogleGenAI").getInstance()
  }

  /** Gets a reference to a sink for prompt content in the Google GenAI SDK. */
  API::Node getSystemOrAssistantPromptNode() {
    exists(API::Node params |
      // ai.models.generateContent({ contents, config })
      // ai.models.generateContentStream({ contents, config })
      params =
        clientRef()
            .getMember("models")
            .getMember(["generateContent", "generateContentStream"])
            .getParameter(0)
    |
      // config.systemInstruction
      result = params.getMember("config").getMember("systemInstruction")
      or
      // contents: [{ role: "model", parts: [{ text: "..." }] }]
      // Gemini uses "model" role instead of "assistant"
      exists(API::Node msg |
        msg = params.getMember("contents").getArrayElement() and
        msg.getMember("role").asSink().mayHaveStringValue("model")
      |
        result = msg.getMember("parts").getArrayElement().getMember("text")
      )
    )
    or
    // ai.chats.create({ config: { systemInstruction: ... } })
    result =
      clientRef()
          .getMember("chats")
          .getMember("create")
          .getParameter(0)
          .getMember("config")
          .getMember("systemInstruction")
    or
    // chat.sendMessage({ config: { systemInstruction: ... } })
    result =
      clientRef()
          .getMember("chats")
          .getMember("create")
          .getReturn()
          .getMember("sendMessage")
          .getParameter(0)
          .getMember("config")
          .getMember("systemInstruction")
    or
    // ai.live.connect({ config: { systemInstruction: ... } })
    result =
      clientRef()
          .getMember("live")
          .getMember("connect")
          .getParameter(0)
          .getMember("config")
          .getMember("systemInstruction")
  }

  /** Gets a reference to nodes where potential user input can land. */
  API::Node getUserPromptNode() {
    exists(API::Node params |
      // ai.models.generateContent({ contents: ... }) / generateContentStream
      params =
        clientRef()
            .getMember("models")
            .getMember(["generateContent", "generateContentStream"])
            .getParameter(0)
    |
      // contents: "string" or contents: [Part]
      result = params.getMember("contents")
      or
      // contents: [{ role: "user", parts: [{ text: "..." }] }]
      exists(API::Node msg |
        msg = params.getMember("contents").getArrayElement() and
        not msg.getMember("role").asSink().mayHaveStringValue("model")
      |
        result = msg.getMember("parts").getArrayElement().getMember("text")
      )
    )
    or
    // ai.models.generateImages({ prompt, config })
    result =
      clientRef()
          .getMember("models")
          .getMember("generateImages")
          .getParameter(0)
          .getMember("prompt")
    or
    // ai.models.editImage({ prompt, referenceImages, config })
    result =
      clientRef()
          .getMember("models")
          .getMember("editImage")
          .getParameter(0)
          .getMember("prompt")
    or
    // ai.models.generateVideos({ prompt, config })
    result =
      clientRef()
          .getMember("models")
          .getMember("generateVideos")
          .getParameter(0)
          .getMember("prompt")
    or
    // chat.sendMessage({ message: ... }) and chat.sendMessageStream({ message: ... })
    exists(API::Node sendParam |
      sendParam =
        clientRef()
            .getMember("chats")
            .getMember("create")
            .getReturn()
            .getMember(["sendMessage", "sendMessageStream"])
            .getParameter(0)
    |
      result = sendParam.getMember("message")
      or
      // chat.sendMessage({ content: [...] }) — used for image editing
      result = sendParam.getMember("content")
    )
    or
    // ai.models.embedContent({ content: ... })
    result =
      clientRef()
          .getMember("models")
          .getMember("embedContent")
          .getParameter(0)
          .getMember("content")
    or
    // ai.interactions.create({ input: ... })
    result =
      clientRef()
          .getMember("interactions")
          .getMember("create")
          .getParameter(0)
          .getMember("input")
  }
}

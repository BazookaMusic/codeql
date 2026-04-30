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
  API::Node getContentNode() {
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
}

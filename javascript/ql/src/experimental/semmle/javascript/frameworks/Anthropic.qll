/**
 * Provides classes modeling security-relevant aspects of the `@anthropic-ai/sdk` package.
 * See https://github.com/anthropics/anthropic-sdk-typescript
 */

private import javascript

module Anthropic {
  /** Gets a reference to the `Anthropic` client instance. */
  API::Node classRef() {
    // Default export: import Anthropic from '@anthropic-ai/sdk'; new Anthropic()
    result = API::moduleImport("@anthropic-ai/sdk").getInstance()
  }


  /** Gets a reference to a sink for the system prompt in the Anthropic messages API. */
  API::Node getContentNode() {
    exists(API::Node createParams |
      // client.messages.create({ ... })
      createParams = classRef()
          .getMember("messages")
          .getMember("create")
          .getParameter(0)
      or
      // client.beta.messages.create({ ... })
      createParams = classRef()
          .getMember("beta")
          .getMember("messages")
          .getMember("create")
          .getParameter(0)
    |
      // system: "string"
      result = createParams.getMember("system")
      or
      // system: [{ type: "text", text: "..." }]
      result = createParams.getMember("system").getArrayElement().getMember("text")
      or
      // messages: [{ role: "assistant", content: "..." }]
      // Injecting content into what the model said from external sources is very likely an injection.
      exists(API::Node msg |
        msg = createParams.getMember("messages").getArrayElement() and
        msg.getMember("role").asSink().mayHaveStringValue("assistant")
      |
        result = msg.getMember("content")
      )
    )
    or
    // client.beta.agents.create({ system: "..." })
    result = classRef()
        .getMember("beta")
        .getMember("agents")
        .getMember("create")
        .getParameter(0)
        .getMember("system")
    or
    // client.beta.agents.update(agentId, { system: "..." })
    result = classRef()
        .getMember("beta")
        .getMember("agents")
        .getMember("update")
        .getParameter(1)
        .getMember("system")
  }
}
/**
 * Provides classes modeling security-relevant aspects of the `openAI-Node` package.
 * See https://github.com/openai/openai-node 
 */

private import javascript

 /** Holds if `msg` is a message array element with a privileged role. */
private predicate isSystemOrDevMessage(API::Node msg) {
  msg.getMember("role").asSink().mayHaveStringValue(["system", "developer", "assistant"])
}

module OpenAI {
  /** Gets a reference to the `openai.OpenAI` class. */
  API::Node classRef() {
    // Default export: import OpenAI from 'openai'; new OpenAI()
    result = API::moduleImport("openai").getInstance()
    or
    // Named import: import { OpenAI, AzureOpenAI } from 'openai'; new AzureOpenAI()
    result = API::moduleImport("openai").getMember(["OpenAI", "AzureOpenAI"]).getInstance()
  }


  /** Gets a reference to a potential property of `openai.OpenAI` called instructions which refers to the system prompt. */
  API::Node getContentNode() {
    // responses.create({ input: ..., instructions: ... })
    // input can be a string or an array of message objects
    exists(API::Node responsesCreate |
      responsesCreate =
        classRef()
            .getMember("responses")
            .getMember("create")
            .getParameter(0)
    |
      // instructions: "string"
      result = responsesCreate.getMember("instructions")
      // intended that user data can flow into input
      // or
      // // input: "string"
      // result = responsesCreate.getMember("input")
      or
      // input: [{ role: "system"/"developer", content: "..." }]
      exists(API::Node msg |
        msg = responsesCreate.getMember("input").getArrayElement() and
        isSystemOrDevMessage(msg)
      |
        result = msg.getMember("content")
      )
    )
    or
    // chat.completions.create({ messages: [{ role: "system"/"developer", content: ... }] })
    // content can be a string or an array of content parts
    exists(API::Node msg, API::Node content |
      msg =
        classRef()
            .getMember("chat")
            .getMember("completions")
            .getMember("create")
            .getParameter(0)
            .getMember("messages")
            .getArrayElement() and
      isSystemOrDevMessage(msg) and
      content = msg.getMember("content")
    |
      // content: "string"
      result = content
      or
      // content: [{ type: "text", text: "..." }]
      result = content.getArrayElement().getMember("text")
    )
    or
    // Legacy completions API: completions.create({ prompt: ... })
    result =
      classRef()
          .getMember("completions")
          .getMember("create")
          .getParameter(0)
          .getMember("prompt")
    or
    // images.generate({ prompt: ... }) and images.edit({ prompt: ... })
    result =
      classRef()
          .getMember("images")
          .getMember(["generate", "edit"])
          .getParameter(0)
          .getMember("prompt")
    or
    // embeddings.create({ input: ... })
    result =
      classRef()
          .getMember("embeddings")
          .getMember("create")
          .getParameter(0)
          .getMember("input")
    or
    // beta.assistants.create({ instructions: ... }) and beta.assistants.update(id, { instructions: ... })
    result =
      classRef()
          .getMember("beta")
          .getMember("assistants")
          .getMember(["create", "update"])
          .getParameter(0)
          .getMember("instructions")
    or
    // beta.threads.runs.create(threadId, { instructions: ..., additional_instructions: ... })
    result =
      classRef()
          .getMember("beta")
          .getMember("threads")
          .getMember("runs")
          .getMember("create")
          .getParameter(1)
          .getMember(["instructions", "additional_instructions"])
    or
    // beta.threads.messages.create(threadId, { role: "system"/"developer", content: ... })
    exists(API::Node msg |
      msg =
        classRef()
            .getMember("beta")
            .getMember("threads")
            .getMember("messages")
            .getMember("create")
            .getParameter(1) and
      isSystemOrDevMessage(msg)
    |
      result = msg.getMember("content")
    )
    or
    // audio.transcriptions.create({ prompt: ... }) and audio.translations.create({ prompt: ... })
    result =
      classRef()
          .getMember("audio")
          .getMember(["transcriptions", "translations"])
          .getMember("create")
          .getParameter(0)
          .getMember("prompt")
  }
}

/**
 * Provides models for agents SDK (instances of the `agents` class etc).
 *
 * See https://github.com/openai/openai-agents-js.
 */
module AgentSDK {
  API::Node moduleRef() { result = API::moduleImport("@openai/agents") }

  /** Gets a reference to the `agents.Runner` class. */
  API::Node agentConstructor() { result = moduleRef().getMember("Agent") }

  API::Node classInstance() { result = agentConstructor().getInstance() }

  /** Gets a reference to the top-level run() or Runner.run() functions. */
  API::Node run() {
    // import { run } from '@openai/agents'; run(agent, input)
    result = moduleRef().getMember("run")
    or
    // const runner = new Runner(); runner.run(agent, input)
    result = moduleRef().getMember("Runner").getInstance().getMember("run")
  }

  API::Node asTool() { result = classInstance().getMember("asTool")}

  API::Node toolFunction() { result = moduleRef().getMember("tool") }

  /** Gets a reference to a potential property of `agents.Runner` called input which can refer to a system prompt depending on the role specified. */
  API::Node getContentNode() {
    // Agent({ instructions: ... })
    result = agentConstructor()
    .getParameter(0)
    .getMember(["instructions", "handoffDescription"])
    or
    // Agent({ instructions: (runContext) => returnValue })
    result = agentConstructor()
    .getParameter(0)
    .getMember("instructions")
    .getReturn()
    or
    // run(agent, input) or runner.run(agent, input) — string input
    result = run()
      .getParameter(1)
    or
    // run(agent, [{ role: "system"/"developer", content: ... }])
    exists(API::Node msg |
      msg = run()
        .getParameter(1)
        .getArrayElement() and
      isSystemOrDevMessage(msg)
    |
      result = msg.getMember("content")
    )
    or
    // agent.asTool({..., toolDescription: ...})
    result = asTool().getParameter(0).getMember("toolDescription")
    or
    // tool({..., description: ...})
    result = toolFunction().getParameter(0).getMember("description")
  }
}

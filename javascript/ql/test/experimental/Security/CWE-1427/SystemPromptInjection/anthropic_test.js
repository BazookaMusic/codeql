const express = require("express");
const Anthropic = require("@anthropic-ai/sdk");

const app = express();
const client = new Anthropic();

app.get("/test", async (req, res) => {
  const persona = req.query.persona;
  const query = req.query.query;

  // === messages.create: system as string ===

  // SHOULD ALERT
  const m1 = await client.messages.create({
    model: "claude-sonnet-4-20250514",
    max_tokens: 1024,
    system: "Talk like a " + persona, // $ Alert[js/prompt-injection]
    messages: [{ role: "user", content: query }],
  });

  // === messages.create: system as TextBlockParam array ===

  // SHOULD ALERT
  const m2 = await client.messages.create({
    model: "claude-sonnet-4-20250514",
    max_tokens: 1024,
    system: [
      {
        type: "text",
        text: "Talk like a " + persona, // $ Alert[js/prompt-injection]
      },
    ],
    messages: [{ role: "user", content: query }],
  });

  // === messages.create: assistant role content ===

  // SHOULD ALERT
  const m3 = await client.messages.create({
    model: "claude-sonnet-4-20250514",
    max_tokens: 1024,
    messages: [
      {
        role: "assistant",
        content: "Talk like a " + persona, // $ Alert[js/prompt-injection]
      },
      { role: "user", content: query },
    ],
  });

  // === messages.create: user role content ===

  // SHOULD NOT ALERT
  const m4 = await client.messages.create({
    model: "claude-sonnet-4-20250514",
    max_tokens: 1024,
    messages: [
      {
        role: "user",
        content: query, // OK - user role
      },
    ],
  });

  // === beta.messages.create: system as string ===

  // SHOULD ALERT
  const bm1 = await client.beta.messages.create({
    model: "claude-sonnet-4-20250514",
    max_tokens: 1024,
    system: "Talk like a " + persona, // $ Alert[js/prompt-injection]
    messages: [{ role: "user", content: query }],
  });

  // === beta.messages.create: system as TextBlockParam array ===

  // SHOULD ALERT
  const bm2 = await client.beta.messages.create({
    model: "claude-sonnet-4-20250514",
    max_tokens: 1024,
    system: [
      {
        type: "text",
        text: "Talk like a " + persona, // $ Alert[js/prompt-injection]
      },
    ],
    messages: [{ role: "user", content: query }],
  });

  // === beta.messages.create: assistant role content ===

  // SHOULD ALERT
  const bm3 = await client.beta.messages.create({
    model: "claude-sonnet-4-20250514",
    max_tokens: 1024,
    messages: [
      {
        role: "assistant",
        content: "Talk like a " + persona, // $ Alert[js/prompt-injection]
      },
      { role: "user", content: query },
    ],
  });

  // === beta.agents.create: system ===

  // SHOULD ALERT
  const ba1 = await client.beta.agents.create({
    model: "claude-sonnet-4-20250514",
    system: "Talk like a " + persona, // $ Alert[js/prompt-injection]
  });

  // === beta.agents.update: system ===

  // SHOULD ALERT
  await client.beta.agents.update("agent_123", {
    system: "Talk like a " + persona, // $ Alert[js/prompt-injection]
  });

  // === Sanitizer: constant comparison ===

  // SHOULD NOT ALERT
  if (persona === "pirate") {
    const m5 = await client.messages.create({
      model: "claude-sonnet-4-20250514",
      max_tokens: 1024,
      system: "Talk like a " + persona, // OK - sanitized by constant check
      messages: [{ role: "user", content: query }],
    });
  }

  res.send("done");
});

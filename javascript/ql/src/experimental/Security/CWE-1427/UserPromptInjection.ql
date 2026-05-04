/**
 * @name User prompt injection
 * @description Untrusted input flowing into a user-role prompt of an AI model
 *              may allow an attacker to manipulate the model's behavior.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 5.0
 * @precision high
 * @id js/user-prompt-injection
 * @tags security
 *       experimental
 *       external/cwe/cwe-1427
 */

import javascript
import experimental.semmle.javascript.security.PromptInjection.UserPromptinjectionQuery
import UserPromptInjectionFlow::PathGraph

from UserPromptInjectionFlow::PathNode source, UserPromptInjectionFlow::PathNode sink
where UserPromptInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This prompt construction depends on a $@.", source.getNode(),
  "user-provided value"

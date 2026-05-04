/**
 * @name Prompt injection
 * @kind path-problem
 * @problem.severity error
 * @security-severity 5.0
 * @precision high
 * @id js/prompt-injection
 * @tags security
 *       experimental
 *       external/cwe/cwe-1427
 */

import javascript
import experimental.semmle.javascript.security.PromptInjection.SystemPromptInjectionQuery
import SystemPromptInjectionFlow::PathGraph

from SystemPromptInjectionFlow::PathNode source, SystemPromptInjectionFlow::PathNode sink
where SystemPromptInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This prompt construction depends on a $@.", source.getNode(),
  "user-provided value"

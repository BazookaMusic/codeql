---
category: majorAnalysis
---
* When resolving dependencies in `build-mode: none`, `dotnet restore` now always receives the NuGet feeds configured in `nuget.config` (if reachable) and any private registries directly, improving reliability when default feeds are unavailable or restricted.

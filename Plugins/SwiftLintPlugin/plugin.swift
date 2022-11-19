import PackagePlugin

@main
struct SwiftLintPlugins: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        [
            .buildCommand(
                displayName: "Linting \(target.name)...",
                executable: try context.tool(named: "swiftlint").path,
                arguments: [
                    "lint",
                    "--config",
                    "\(context.package.directory.string)/.swiftlint.yml"
                ],
                environment: [:]
            )
        ]
    }
}

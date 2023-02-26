import PackagePlugin
import Foundation

#if true
@main
struct CreateXCFrameworkPlugin: BuildToolPlugin {
	func createBuildCommands(
		context: PackagePlugin.PluginContext,
		target: PackagePlugin.Target) async throws -> [PackagePlugin.Command] {
			
		}

}
#else
@main
struct CreateXCFrameworkPlugin: CommandPlugin {

	func performCommand(
		context: PluginContext,
		arguments: [String]) async throws
	{
		let createXCFrameworkTool = try context.tool(named: "CreateXCFramework")
		let createXCFrameworkExec = URL(fileURLWithPath: createXCFrameworkTool.path.string)

		for target in context.package.targets {
			guard let target = target as? SourceModuleTarget else { continue }

			let process = Process()
			process.executableURL = createXCFrameworkExec
			process.arguments = [
				"\(target.directory)",
			]
			try process.run()
			process.waitUntilExit()

			if process.terminationReason == .exit && process.terminationStatus == 0 {
				print("Formatted the source code in \(target.directory).")
			} else {
				let problem = "\(process.terminationReason):\(process.terminationStatus)"
				Diagnostics.error("swift-format invocation failed: \(problem)")
			}
		}
	}
}
#endif

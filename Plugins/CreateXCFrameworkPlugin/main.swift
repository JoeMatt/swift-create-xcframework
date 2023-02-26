import PackagePlugin
import Foundation

@main
struct CreateXCFrameworkPlugin: CommandPlugin {

	func performCommand(context: PluginContext, arguments: [String]) throws {
		let createXCFrameworkTool = try context.tool(named: "swift-create-xcframework")
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
			}
			else {
				let problem = "\(process.terminationReason):\(process.terminationStatus)"
				Diagnostics.error("swift-format invocation failed: \(problem)")
			}
		}
	}
}

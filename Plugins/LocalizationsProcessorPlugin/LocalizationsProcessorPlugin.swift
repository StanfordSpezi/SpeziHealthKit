//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import PackagePlugin


@main
struct LocalizationsProcessorPlugin: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) throws {
        let tool = try context.tool(named: "LocalizationsProcessor")
        let process = Process()
        process.currentDirectoryURL = context.pluginWorkDirectoryURL
        process.executableURL = tool.url
        process.arguments = arguments
        try process.run()
        process.waitUntilExit()
        switch process.terminationReason {
        case .exit:
            Diagnostics.remark("Completed localization processing.")
        case .uncaughtSignal:
            Diagnostics.error("Error processing localization.")
        @unknown default:
            Diagnostics.error("Unhandled termination.")
        }
    }
}

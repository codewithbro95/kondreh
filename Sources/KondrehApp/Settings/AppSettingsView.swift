import AppKit
import KondrehCore
import SwiftUI

enum AppSettingsSection: String, CaseIterable, Identifiable {
    case general
    case about
    case floatingWindow
    case frameShape
    case notchShortcut
    case audioPulse
    case reactionHints
    case icons

    var id: String { rawValue }

    static let primarySections: [AppSettingsSection] = [.general, .about]
    static let featureSections: [AppSettingsSection] = [
        .floatingWindow,
        .frameShape,
        .notchShortcut,
        .audioPulse,
        .reactionHints,
        .icons
    ]

    var title: String {
        switch self {
        case .general: "General"
        case .about: "About"
        case .floatingWindow: "Floating Window"
        case .frameShape: "Frame Shape"
        case .notchShortcut: "Notch Shortcut"
        case .audioPulse: "Audio Pulse"
        case .reactionHints: "Reaction Hints"
        case .icons: "Icons"
        }
    }

    var symbolName: String {
        switch self {
        case .general: "gearshape"
        case .about: "info.circle"
        case .floatingWindow: "macwindow"
        case .frameShape: "viewfinder"
        case .notchShortcut: "laptopcomputer"
        case .audioPulse: "waveform"
        case .reactionHints: "sparkles"
        case .icons: "square.grid.2x2"
        }
    }

    var badge: String? {
        nil
    }
}

final class SettingsNavigation: ObservableObject {
    @Published var selection: AppSettingsSection = .general

    func select(_ section: AppSettingsSection) {
        selection = section
    }
}

struct AppSettingsView: View {
    @ObservedObject var environment: AppEnvironment
    @ObservedObject var navigation: SettingsNavigation
    @ObservedObject private var settings: SettingsService

    init(environment: AppEnvironment, navigation: SettingsNavigation = SettingsNavigation()) {
        self.environment = environment
        self.navigation = navigation
        self.settings = environment.settings
    }

    var body: some View {
        NavigationSplitView {
            List(selection: selectionBinding) {
                Section {
                    ForEach(AppSettingsSection.primarySections) { section in
                        SettingsSidebarLabel(section: section)
                            .tag(section)
                    }
                }

                Section(AppConstants.appName) {
                    ForEach(AppSettingsSection.featureSections) { section in
                        SettingsSidebarLabel(section: section)
                            .tag(section)
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 190, ideal: 220, max: 260)
            .safeAreaInset(edge: .top) {
                Color.clear.frame(height: 18)
            }
        } detail: {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        selectedPage
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(.horizontal, 24)
                    .padding(.top, 18)
                    .padding(.bottom, 28)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle(navigation.selection.title)
        }
        .frame(minWidth: 720, idealWidth: 760, minHeight: 560, idealHeight: 600)
        .background(Color(nsColor: .windowBackgroundColor))
        .preferredColorScheme(settings.appearance.colorScheme)
    }

    private var selectionBinding: Binding<AppSettingsSection?> {
        Binding {
            navigation.selection
        } set: { selection in
            if let selection {
                navigation.selection = selection
            }
        }
    }

    @ViewBuilder
    private var selectedPage: some View {
        switch navigation.selection {
        case .general:
            GeneralSettingsPage(environment: environment)
        case .about:
            AboutSettingsPage()
        case .floatingWindow:
            FloatingWindowSettingsPage(settings: settings)
        case .frameShape:
            FrameShapeSettingsPage(settings: settings)
        case .notchShortcut:
            NotchShortcutSettingsPage(settings: settings)
        case .audioPulse:
            AudioPulseSettingsPage(settings: settings)
        case .reactionHints:
            ReactionHintsSettingsPage(settings: settings)
        case .icons:
            IconsSettingsPage(settings: settings)
        }
    }
}

private struct SettingsSidebarLabel: View {
    var section: AppSettingsSection

    var body: some View {
        HStack(spacing: 9) {
            Label(section.title, systemImage: section.symbolName)

            if let badge = section.badge {
                Spacer()
                Text(badge)
                    .font(.system(size: 9, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 5, style: .continuous))
                    .foregroundStyle(.white)
            }
        }
    }
}

private struct GeneralSettingsPage: View {
    @ObservedObject var environment: AppEnvironment
    @ObservedObject private var settings: SettingsService
    @ObservedObject private var launchAtLogin: LaunchAtLoginService

    init(environment: AppEnvironment) {
        self.environment = environment
        self.settings = environment.settings
        self.launchAtLogin = environment.launchAtLoginService
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            SettingsCard(title: "Appearance") {
                SettingsRow("Menu bar symbol", subtitle: "Pick the tiny icon that sits in the macOS menu bar.") {
                    MenuBarIconStrip(selection: $settings.menuBarIconStyle)
                        .frame(width: 210)
                }

                SettingsDivider()

                SettingsToggleRow("Show icon in Dock", isOn: showDockIconBinding)
            }

            SettingsCard(title: "General") {
                SettingsRow("Keyboard shortcut") {
                    ShortcutRecorderView(shortcut: shortcutBinding)
                        .frame(width: 148, height: 30)
                        .help("Click, then press a supported shortcut")
                }

                SettingsDivider()

                SettingsRow("Preview size") {
                    Picker("", selection: popoverSizeBinding) {
                        ForEach(PopoverSize.allCases) { size in
                            Text(size.title).tag(size)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 150)
                }

                SettingsDivider()

                SettingsToggleRow("Mirror preview", subtitle: "Useful when you want the preview to feel like a mirror.", isOn: $settings.mirrorPreview)

                SettingsDivider()

                SettingsRow("Close preview when") {
                    Picker("", selection: closeBehaviorBinding) {
                        ForEach(CloseBehavior.allCases) { behavior in
                            Text(behavior.title).tag(behavior)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 170)
                }
            }

            SettingsCard {
                SettingsToggleRow("Start at login", isOn: launchAtLoginBinding)

                if let error = launchAtLogin.lastError {
                    SettingsDivider()
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                }
            }
        }
    }

    private var launchAtLoginBinding: Binding<Bool> {
        Binding {
            launchAtLogin.state == .enabled
        } set: { enabled in
            settings.launchAtLogin = enabled
            launchAtLogin.setEnabled(enabled)
        }
    }

    private var showDockIconBinding: Binding<Bool> {
        Binding {
            settings.showDockIcon
        } set: { enabled in
            settings.showDockIcon = enabled
            NSApp.setActivationPolicy(enabled ? .regular : .accessory)
        }
    }

    private var shortcutBinding: Binding<GlobalKeyboardShortcut> {
        Binding {
            settings.keyboardShortcut
        } set: { shortcut in
            settings.keyboardShortcut = shortcut
            (NSApp.delegate as? AppDelegate)?.configureShortcut()
        }
    }

    private var popoverSizeBinding: Binding<PopoverSize> {
        Binding {
            PopoverSize.closest(to: settings.panelSize)
        } set: { size in
            settings.panelSize = size.dimensions
        }
    }

    private var closeBehaviorBinding: Binding<CloseBehavior> {
        Binding {
            settings.closeOnOutsideClick ? .outsideClick : .manual
        } set: { behavior in
            settings.closeOnOutsideClick = behavior == .outsideClick
        }
    }
}

private struct AboutSettingsPage: View {
    var body: some View {
        VStack(spacing: 18) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .scaledToFit()
                .frame(width: 128, height: 128)
                .shadow(color: .black.opacity(0.22), radius: 18, y: 12)
                .accessibilityHidden(true)

            SettingsCard {
                SettingsRow("Made by") {
                    Text(AppConstants.developerName)
                        .foregroundStyle(.secondary)
                }

                SettingsDivider()

                SettingsRow("Special thanks") {
                    Text("the internet")
                        .foregroundStyle(.secondary)
                }
            }

            SettingsCard {
                SettingsRow("App version") {
                    Text("\(version) (\(build))")
                        .foregroundStyle(.secondary)
                }

                SettingsDivider()

                SettingsRow("License") {
                    Text("No license needed. Kondreh is free.")
                        .foregroundStyle(.secondary)
                }

                SettingsDivider()

                SettingsRow("Support") {
                    VStack(alignment: .trailing, spacing: 7) {
                        Button("Email support") {
                            SettingsActions.openSupport(subject: "Kondreh support")
                        }
                        .buttonStyle(.link)

                        Button("Developer website") {
                            SettingsActions.openWebsite()
                        }
                        .buttonStyle(.link)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1.0"
    }

    private var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

private struct FloatingWindowSettingsPage: View {
    @ObservedObject var settings: SettingsService

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            SettingsCard {
                SettingsRow("Window style") {
                    HStack(spacing: 12) {
                        WindowModeChoice(mode: .floatingWindow, selection: $settings.previewWindowMode)
                        WindowModeChoice(mode: .popover, selection: $settings.previewWindowMode)
                    }
                }

                SettingsDivider()

                SettingsRow("Window position", subtitle: "The preview opens near the active display unless you place it yourself.") {
                    ScreenPlacementPreview()
                        .frame(width: 230, height: 118)
                }
            }

            SettingsCard {
                SettingsToggleRow("Lock aspect ratio", isOn: $settings.lockAspectRatio)

                SettingsDivider()

                SettingsToggleRow("Remember manual position", subtitle: "Keep your custom placement instead of recentering each time.", isOn: $settings.manualWindowPosition)
            }

            SettingsCard {
                SettingsToggleRow("Keep preview in front", isOn: $settings.alwaysOnTop)

                SettingsDivider()

                SettingsToggleRow("Close after focus leaves", isOn: $settings.closeOnOutsideClick)
            }
        }
    }
}

private struct FrameShapeSettingsPage: View {
    @ObservedObject var settings: SettingsService

    var body: some View {
        SettingsCard {
            SettingsRow("Shape") {
                HStack(spacing: 14) {
                    ForEach(WindowMaskStyle.allCases) { style in
                        MaskStyleChoice(style: style, selection: $settings.windowMaskStyle)
                    }
                }
            }

            SettingsDivider()

            SliderRow(title: "Zoom", valueText: String(format: "%.1fx", settings.maskZoom)) {
                Slider(value: $settings.maskZoom, in: 1...3, step: 0.1)
            }

            SettingsDivider()

            SliderRow(title: "Rotation", valueText: "\(Int(settings.maskRotation)) deg") {
                Slider(value: $settings.maskRotation, in: 0...270, step: 15)
            }
        }
    }
}

private struct NotchShortcutSettingsPage: View {
    @ObservedObject var settings: SettingsService

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            NotchPreview()

            SettingsCard {
                SettingsToggleRow("Enable Notch Shortcut", subtitle: "Click behind the built-in camera area to show Kondreh.", isOn: notchEnabledBinding)

                SettingsDivider()

                SettingsToggleRow("Hide menu bar icon", subtitle: "When the notch shortcut is enabled, keep the menu bar tidy.", isOn: hideMenuIconBinding)
            }

            Text("This can feel different depending on the display and other apps that watch notch clicks.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 10)
        }
    }

    private var notchEnabledBinding: Binding<Bool> {
        Binding {
            settings.notchTriggerEnabled
        } set: { enabled in
            settings.notchTriggerEnabled = enabled
            if enabled, settings.hideMenuBarIconForNotch {
                settings.showMenuBarIcon = false
            } else if enabled == false {
                settings.showMenuBarIcon = true
            }
        }
    }

    private var hideMenuIconBinding: Binding<Bool> {
        Binding {
            settings.hideMenuBarIconForNotch
        } set: { hidden in
            settings.hideMenuBarIconForNotch = hidden
            if settings.notchTriggerEnabled {
                settings.showMenuBarIcon = hidden == false
            }
        }
    }
}

private struct AudioPulseSettingsPage: View {
    @ObservedObject var settings: SettingsService

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            AudioPulsePreview()

            SettingsCard {
                SettingsToggleRow("Enable Audio Pulse", subtitle: "Show a small level check before joining a call.", isOn: $settings.micCheckEnabled)

                SettingsDivider()

                SettingsToggleRow("Show only on hover", subtitle: "Keep the preview cleaner until you move the pointer over it.", isOn: $settings.micCheckHoverOnly)
            }
        }
    }
}

private struct ReactionHintsSettingsPage: View {
    @ObservedObject var settings: SettingsService

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ReactionsPreview()

            SettingsCard {
                SettingsToggleRow("Show reaction hints", subtitle: "Surface macOS camera reaction gestures from the preview.", isOn: $settings.reactionsEnabled)
            }
        }
    }
}

private struct IconsSettingsPage: View {
    @ObservedObject var settings: SettingsService

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            SettingsCard {
                SettingsRow("Menu bar symbol") {
                    MenuBarIconGrid(selection: $settings.menuBarIconStyle)
                }
            }

            SettingsCard {
                SettingsToggleRow("Show icon in Dock", isOn: showDockIconBinding)

                SettingsDivider()

                SettingsRow("App icon") {
                    AppIconGrid(selection: $settings.alternateAppIconStyle)
                }
            }
        }
    }

    private var showDockIconBinding: Binding<Bool> {
        Binding {
            settings.showDockIcon
        } set: { enabled in
            settings.showDockIcon = enabled
            NSApp.setActivationPolicy(enabled ? .regular : .accessory)
        }
    }
}

private struct SettingsCard<Content: View>: View {
    var title: String?
    @ViewBuilder var content: Content

    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .padding(.leading, 10)
            }

            VStack(spacing: 0) {
                content
            }
            .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }
}

private struct SettingsRow<Trailing: View>: View {
    var title: String
    var subtitle: String?
    @ViewBuilder var trailing: () -> Trailing

    init(_ title: String, subtitle: String? = nil, @ViewBuilder trailing: @escaping () -> Trailing) {
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.primary)

                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer(minLength: 16)

            trailing()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(minHeight: 44)
    }
}

private struct SettingsToggleRow: View {
    var title: String
    var subtitle: String?
    @Binding var isOn: Bool

    init(_ title: String, subtitle: String? = nil, isOn: Binding<Bool>) {
        self.title = title
        self.subtitle = subtitle
        self._isOn = isOn
    }

    var body: some View {
        SettingsRow(title, subtitle: subtitle) {
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(.switch)
                .controlSize(.small)
        }
    }
}

private struct SettingsDivider: View {
    var body: some View {
        Divider()
            .padding(.leading, 12)
    }
}

private struct SliderRow<SliderContent: View>: View {
    var title: String
    var valueText: String
    @ViewBuilder var slider: () -> SliderContent

    var body: some View {
        SettingsRow(title) {
            HStack(spacing: 10) {
                slider()
                    .frame(width: 230)

                Text(valueText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 48, alignment: .trailing)
            }
        }
    }
}

private struct MenuBarIconStrip: View {
    @Binding var selection: MenuBarIconStyle

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(MenuBarIconStyle.allCases.prefix(4))) { style in
                SymbolChoiceButton(
                    title: style.displayName,
                    symbolName: style.symbolName,
                    isSelected: selection == style,
                    compact: true
                ) {
                    selection = style
                }
            }
        }
    }
}

private struct MenuBarIconGrid: View {
    @Binding var selection: MenuBarIconStyle

    private let columns = [
        GridItem(.fixed(58), spacing: 10),
        GridItem(.fixed(58), spacing: 10),
        GridItem(.fixed(58), spacing: 10)
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .trailing, spacing: 10) {
            ForEach(MenuBarIconStyle.allCases) { style in
                SymbolChoiceButton(
                    title: style.displayName,
                    symbolName: style.symbolName,
                    isSelected: selection == style,
                    compact: false
                ) {
                    selection = style
                }
            }
        }
        .frame(width: 196)
    }
}

private struct AppIconGrid: View {
    @Binding var selection: AppIconStyle

    private let columns = [
        GridItem(.fixed(64), spacing: 14),
        GridItem(.fixed(64), spacing: 14),
        GridItem(.fixed(64), spacing: 14)
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .trailing, spacing: 12) {
            ForEach(AppIconStyle.allCases) { style in
                Button {
                    selection = style
                    AppIconApplier.apply(style, updateBundleIcon: true)
                } label: {
                    VStack(spacing: 6) {
                        Image(nsImage: AppIconApplier.previewImage(for: style))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(selection == style ? Color.accentColor : Color.clear, lineWidth: 2)
                        }

                        Text(style.displayName)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(selection == style ? .primary : .secondary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .frame(width: 220)
    }
}

private struct SymbolChoiceButton: View {
    var title: String
    var symbolName: String
    var isSelected: Bool
    var compact: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: compact ? 0 : 4) {
                Image(systemName: symbolName)
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 40, height: 34)
                    .background(Color(nsColor: .windowBackgroundColor), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                    }

                if compact == false {
                    Text(title)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(isSelected ? .primary : .secondary)
                        .lineLimit(1)
                }
            }
        }
        .buttonStyle(.plain)
        .help(title)
    }
}

private struct WindowModeChoice: View {
    var mode: PreviewWindowMode
    @Binding var selection: PreviewWindowMode

    var body: some View {
        Button {
            selection = mode
        } label: {
            VStack(spacing: 6) {
                ZStack(alignment: mode == .popover ? .top : .center) {
                    RoundedRectangle(cornerRadius: mode == .popover ? 8 : 4, style: .continuous)
                        .fill(Color.secondary.opacity(0.28))
                        .frame(width: 86, height: 50)

                    if mode == .floatingWindow {
                        HStack(spacing: 4) {
                            Circle().fill(.secondary.opacity(0.5)).frame(width: 5, height: 5)
                            Circle().fill(.secondary.opacity(0.5)).frame(width: 5, height: 5)
                            Circle().fill(.secondary.opacity(0.5)).frame(width: 5, height: 5)
                            Spacer()
                        }
                        .padding(6)
                    } else {
                        Capsule()
                            .fill(Color(nsColor: .windowBackgroundColor))
                            .frame(width: 18, height: 7)
                            .offset(y: -4)
                    }
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(selection == mode ? Color.accentColor : Color.clear, lineWidth: 2)
                }

                Text(mode.displayName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(selection == mode ? .primary : .secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct MaskStyleChoice: View {
    var style: WindowMaskStyle
    @Binding var selection: WindowMaskStyle

    var body: some View {
        Button {
            selection = style
        } label: {
            VStack(spacing: 6) {
                shapeView
                    .frame(width: 64, height: 50)

                Text(style.displayName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(selection == style ? .primary : .secondary)
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var shapeView: some View {
        switch style {
        case .rounded:
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.secondary.opacity(0.32))
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(selection == style ? Color.accentColor : Color.clear, lineWidth: 2)
                }
        case .square:
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(Color.secondary.opacity(0.32))
                .overlay {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .stroke(selection == style ? Color.accentColor : Color.clear, lineWidth: 2)
                }
        case .circle:
            Circle()
                .fill(Color.secondary.opacity(0.32))
                .overlay {
                    Circle()
                        .stroke(selection == style ? Color.accentColor : Color.clear, lineWidth: 2)
                }
        }
    }
}

private struct ScreenPlacementPreview: View {
    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(LinearGradient(colors: [.indigo.opacity(0.65), .blue.opacity(0.25)], startPoint: .topLeading, endPoint: .bottomTrailing))

            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(.white.opacity(0.22))
                .frame(width: 34, height: 24)
                .padding(12)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private struct NotchPreview: View {
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(LinearGradient(colors: [.orange.opacity(0.35), .black.opacity(0.5)], startPoint: .bottomLeading, endPoint: .topTrailing))

            VStack(spacing: 0) {
                Capsule()
                    .fill(.black)
                    .frame(width: 110, height: 18)
                    .padding(.bottom, 10)

                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.cyan.opacity(0.35))
                    .frame(width: 230, height: 118)
                    .overlay {
                        Image(systemName: "laptopcomputer")
                            .font(.system(size: 44, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.82))
                    }
            }
        }
        .frame(height: 210)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct AudioPulsePreview: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(LinearGradient(colors: [.gray.opacity(0.38), .black.opacity(0.52)], startPoint: .topLeading, endPoint: .bottomTrailing))

            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.black.opacity(0.42))
                .frame(width: 250, height: 110)
                .overlay(alignment: .bottomLeading) {
                    HStack(alignment: .bottom, spacing: 4) {
                        ForEach(0..<12, id: \.self) { index in
                            Capsule()
                                .fill(index < 8 ? Color.green : Color.white.opacity(0.35))
                                .frame(width: 5, height: CGFloat(10 + (index % 5) * 7))
                        }
                    }
                    .padding(12)
                }
        }
        .frame(height: 210)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct ReactionsPreview: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(LinearGradient(colors: [.gray.opacity(0.36), .black.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))

            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.black.opacity(0.45))
                .frame(width: 270, height: 145)
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .padding(8)
                        .background(.regularMaterial, in: Circle())
                        .padding(8)
                }
                .overlay(alignment: .bottom) {
                    HStack(spacing: 8) {
                        ForEach(["hand.thumbsup.fill", "heart.fill", "sparkles", "face.smiling.fill"], id: \.self) { symbol in
                            Image(systemName: symbol)
                                .font(.system(size: 12, weight: .semibold))
                                .padding(6)
                                .background(.regularMaterial, in: Circle())
                        }
                    }
                    .padding(.bottom, 10)
                }
                .padding(.bottom, 18)
        }
        .frame(height: 210)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private enum PopoverSize: String, CaseIterable, Identifiable {
    case small
    case medium
    case large

    var id: String { rawValue }

    var title: String {
        switch self {
        case .small: "Small"
        case .medium: "Medium"
        case .large: "Large"
        }
    }

    var dimensions: CGSizeValue {
        switch self {
        case .small: CGSizeValue(width: 360, height: 190)
        case .medium: CGSizeValue(width: 404, height: 214)
        case .large: CGSizeValue(width: 424, height: 236)
        }
    }

    static func closest(to size: CGSizeValue) -> PopoverSize {
        if size.width < 390 {
            return .small
        }
        if size.width > 414 {
            return .large
        }
        return .medium
    }
}

private enum CloseBehavior: String, CaseIterable, Identifiable {
    case manual
    case outsideClick

    var id: String { rawValue }

    var title: String {
        switch self {
        case .manual: "Only when closed"
        case .outsideClick: "Clicking outside"
        }
    }
}

private enum SettingsActions {
    static func openSupport(subject: String) {
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? subject
        if let url = URL(string: "mailto:\(AppConstants.supportEmail)?subject=\(encodedSubject)") {
            NSWorkspace.shared.open(url)
        }
    }

    static func openWebsite() {
        guard let url = URL(string: AppConstants.websiteURLString),
              let scheme = url.scheme,
              scheme.hasPrefix("http") else {
            openSupport(subject: "Kondreh website")
            return
        }
        NSWorkspace.shared.open(url)
    }
}

@MainActor
enum AppIconApplier {
    private static var originalIcon: NSImage?

    static func apply(_ style: AppIconStyle, updateBundleIcon: Bool) {
        rememberOriginalIcon()
        let image = previewImage(for: style)
        NSApp.applicationIconImage = image

        guard updateBundleIcon else {
            return
        }

        let bundlePath = Bundle.main.bundlePath
        if style == .standard {
            NSWorkspace.shared.setIcon(nil, forFile: bundlePath, options: [])
        } else {
            NSWorkspace.shared.setIcon(image, forFile: bundlePath, options: [])
        }
    }

    static func previewImage(for style: AppIconStyle) -> NSImage {
        rememberOriginalIcon()
        if style == .standard, let originalIcon {
            return originalIcon
        }

        let size = NSSize(width: 1024, height: 1024)
        let image = NSImage(size: size)
        image.lockFocus()
        defer { image.unlockFocus() }

        let rect = NSRect(origin: .zero, size: size)
        let shape = NSBezierPath(roundedRect: rect.insetBy(dx: 36, dy: 36), xRadius: 210, yRadius: 210)
        shape.addClip()

        backgroundGradient(for: style).draw(in: rect, angle: -35)
        drawDepth(in: rect)
        drawSymbol(for: style, in: rect)

        return image
    }

    private static func rememberOriginalIcon() {
        if originalIcon == nil {
            originalIcon = NSImage(named: "AppIcon") ?? NSApp.applicationIconImage.copy() as? NSImage
        }
    }

    private static func backgroundGradient(for style: AppIconStyle) -> NSGradient {
        switch style {
        case .standard:
            NSGradient(colors: [.black, .darkGray])!
        case .focus:
            NSGradient(colors: [NSColor(calibratedRed: 0.62, green: 0.08, blue: 0.12, alpha: 1), .black])!
        case .studio:
            NSGradient(colors: [NSColor(calibratedRed: 0.08, green: 0.24, blue: 0.62, alpha: 1), NSColor(calibratedRed: 0.5, green: 0.18, blue: 0.8, alpha: 1)])!
        case .midnight:
            NSGradient(colors: [NSColor(calibratedRed: 0.08, green: 0.1, blue: 0.24, alpha: 1), .black])!
        case .classic:
            NSGradient(colors: [NSColor(calibratedRed: 0.36, green: 0.2, blue: 0.12, alpha: 1), NSColor(calibratedRed: 0.88, green: 0.48, blue: 0.18, alpha: 1)])!
        case .soft:
            NSGradient(colors: [NSColor(calibratedRed: 0.12, green: 0.48, blue: 0.42, alpha: 1), NSColor(calibratedRed: 0.42, green: 0.86, blue: 0.74, alpha: 1)])!
        }
    }

    private static func drawDepth(in rect: NSRect) {
        NSColor.white.withAlphaComponent(0.12).setFill()
        NSBezierPath(ovalIn: NSRect(x: rect.midX - 240, y: rect.midY - 180, width: 480, height: 480)).fill()
        NSColor.black.withAlphaComponent(0.18).setFill()
        NSBezierPath(roundedRect: rect.insetBy(dx: 70, dy: 70), xRadius: 180, yRadius: 180).stroke()
    }

    private static func drawSymbol(for style: AppIconStyle, in rect: NSRect) {
        let symbolRect = NSRect(x: rect.midX - 220, y: rect.midY - 220, width: 440, height: 440)
        let symbol = NSImage(systemSymbolName: style.symbolName, accessibilityDescription: nil)?
            .withSymbolConfiguration(.init(pointSize: 330, weight: .semibold))
        symbol?.isTemplate = true

        NSGraphicsContext.saveGraphicsState()
        NSColor.white.withAlphaComponent(0.9).set()
        symbol?.draw(in: symbolRect, from: .zero, operation: .sourceOver, fraction: 1)
        NSGraphicsContext.restoreGraphicsState()
    }
}

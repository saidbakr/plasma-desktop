/*
    SPDX-FileCopyrightText: 2012 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.1
import QtQml 2.15

import org.kde.plasma.core as PlasmaCore
import org.kde.ksvg 1.0 as KSvg
import org.kde.taskmanager 0.1 as TaskManager
import org.kde.kwindowsystem 1.0
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.shell.panel 0.1 as Panel

import org.kde.plasma.plasmoid 2.0

Item {
    id: root

    property Item containment

    property bool floatingPrefix: floatingPanelSvg.usedPrefix === "floating"
    readonly property bool verticalPanel: containment?.plasmoid?.formFactor === PlasmaCore.Types.Vertical

    readonly property real spacingAtMinSize: Math.round(Math.max(1, (verticalPanel ? root.width : root.height) - Kirigami.Units.iconSizes.smallMedium)/2)
    KSvg.FrameSvgItem {
        id: thickPanelSvg
        visible: false
        prefix: 'thick'
        imagePath: "widgets/panel-background"
    }
    KSvg.FrameSvgItem {
        id: floatingPanelSvg
        visible: false
        prefix: ['floating', '']
        imagePath: "widgets/panel-background"
    }

    // NOTE: Many of the properties in this file are accessed directly in C++ PanelView!
    // If you change these, make sure to also correct the related code in panelview.cpp.

    readonly property bool topEdge: containment?.plasmoid?.location === PlasmaCore.Types.TopEdge
    readonly property bool leftEdge: containment?.plasmoid?.location === PlasmaCore.Types.LeftEdge
    readonly property bool rightEdge: containment?.plasmoid?.location === PlasmaCore.Types.RightEdge
    readonly property bool bottomEdge: containment?.plasmoid?.location === PlasmaCore.Types.BottomEdge

    readonly property int topPadding: Math.round(Math.min(thickPanelSvg.fixedMargins.top + Kirigami.Units.smallSpacing, spacingAtMinSize));
    readonly property int bottomPadding: Math.round(Math.min(thickPanelSvg.fixedMargins.bottom + Kirigami.Units.smallSpacing, spacingAtMinSize));
    readonly property int leftPadding: Math.round(Math.min(thickPanelSvg.fixedMargins.left + Kirigami.Units.smallSpacing, spacingAtMinSize));
    readonly property int rightPadding: Math.round(Math.min(thickPanelSvg.fixedMargins.right + Kirigami.Units.smallSpacing, spacingAtMinSize));

    readonly property int fixedBottomFloatingPadding: floating && (floatingPrefix ? floatingPanelSvg.fixedMargins.bottom : 8)
    readonly property int fixedLeftFloatingPadding: floating && (floatingPrefix ? floatingPanelSvg.fixedMargins.left   : 8)
    readonly property int fixedRightFloatingPadding: floating && (floatingPrefix ? floatingPanelSvg.fixedMargins.right  : 8)
    readonly property int fixedTopFloatingPadding: floating && (floatingPrefix ? floatingPanelSvg.fixedMargins.top    : 8)

    // Not rounded to smoothen the animation
    readonly property real bottomFloatingPadding: fixedBottomFloatingPadding * floatingness
    readonly property real leftFloatingPadding: fixedLeftFloatingPadding * floatingness
    readonly property real rightFloatingPadding: fixedRightFloatingPadding * floatingness
    readonly property real topFloatingPadding: fixedTopFloatingPadding * floatingness

    readonly property int minPanelHeight: translucentItem.minimumDrawingHeight
    readonly property int minPanelWidth: translucentItem.minimumDrawingWidth

    TaskManager.VirtualDesktopInfo {
        id: virtualDesktopInfo
    }

    TaskManager.ActivityInfo {
        id: activityInfo
    }

    // We need to have a little gap between the raw visibleWindowsModel count
    // and actually determining if a window is touching.
    // This is because certain dialog windows start off with a position of (screenwidth/2, screenheight/2)
    // and they register as "touching" in the split-second before KWin can place them correctly.
    // This avoids the panel flashing if it is auto-hide etc and such a window is shown.
    // Examples of such windows: properties of a file on desktop, or portal "open with" dialog
    property bool touchingWindow: false
    property bool touchingWindowDirect: visibleWindowsModel.count > 0
    property bool showingDesktop: KWindowSystem.showingDesktop
    Timer {
        id: touchingWindowDebounceTimer
        interval: 10  // ms, I find that this value is enough while not causing unresponsiveness while dragging windows close
        onTriggered: root.touchingWindow = !KWindowSystem.showingDesktop && root.touchingWindowDirect
    }
    onTouchingWindowDirectChanged: touchingWindowDebounceTimer.start()
    onShowingDesktopChanged: touchingWindowDebounceTimer.start()

    TaskManager.TasksModel {
        id: visibleWindowsModel
        filterByVirtualDesktop: true
        filterByActivity: true
        filterByScreen: false
        filterByRegion: TaskManager.RegionFilterMode.Intersect
        filterHidden: true
        filterMinimized: true

        screenGeometry: panel.screenGeometry
        virtualDesktop: virtualDesktopInfo.currentDesktop
        activity: activityInfo.currentActivity

        groupMode: TaskManager.TasksModel.GroupDisabled

        Binding on regionGeometry {
            delayed: true

            // This makes the panel de-float when a window is 12px from it or less.
            // 12px is chosen to avoid any potential issue with kwin snapping behavior,
            // and it looks like the panel hides away from the active window.
            property int defloatDistance: 12
            // Instead, we will only dodge an active panel if the panel is covered by it,
            // i.e. if the window touches at least one pixel of the panel
            property int dodgeDistance: -1
            // We don't have to worry about dealing with both at the same time since
            // dodge-window panels never de-float.

            value: panel.width, panel.height, panel.x, panel.y, panel.dogdeGeometryByDistance(panel.visibilityMode === Panel.Global.DodgeWindows ? dodgeDistance : defloatDistance)
        }
    }

    Connections {
        target: root.containment?.plasmoid ?? null
        function onActivated() {
            if (root.containment.plasmoid.status === PlasmaCore.Types.AcceptingInputStatus) {
                root.containment.plasmoid.status = PlasmaCore.Types.PassiveStatus;
            } else {
                root.containment.plasmoid.status = PlasmaCore.Types.AcceptingInputStatus;
            }
        }
    }

    // Floatingness is a value in [0, 1] that's multiplied to the floating margin; 0: not floating, 1: floating, between 0 and 1: animation between the two states
    property double floatingness
    // PanelOpacity is a value in [0, 1] that's used as the opacity of the opaque elements over the transparent ones; values between 0 and 1 are used for animations
    property double panelOpacity
    Behavior on floatingness {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.OutCubic
        }
    }
    Behavior on panelOpacity {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.OutCubic
        }
    }

    // This value is read from panelview.cpp and disables shadow for floating panels, as they'd be detached from the panel
    property bool hasShadows: floatingness < 0.5
    property var panelMask: floatingness === 0 ? (panelOpacity === 1 ? opaqueItem.mask : translucentItem.mask) : (panelOpacity === 1 ? floatingOpaqueItem.mask : floatingTranslucentItem.mask)

    // These two values are read from panelview.cpp and are used as an offset for the mask
    property int maskOffsetX: floatingTranslucentItem.x
    property int maskOffsetY: floatingTranslucentItem.y

    KSvg.FrameSvgItem {
        id: translucentItem
        visible: floatingness === 0 && panelOpacity !== 1
        enabledBorders: panel.enabledBorders
        anchors.fill: floatingTranslucentItem
        imagePath: containment?.plasmoid?.backgroundHints === PlasmaCore.Types.NoBackground ? "" : "widgets/panel-background"
    }
    KSvg.FrameSvgItem {
        id: floatingTranslucentItem
        visible: floatingness !== 0 && panelOpacity !== 1
        x: root.leftEdge ? fixedLeftFloatingPadding + fixedRightFloatingPadding * (1 - floatingness) : leftFloatingPadding
        y: root.topEdge ? fixedTopFloatingPadding + fixedBottomFloatingPadding * (1 - floatingness) : topFloatingPadding
        width: verticalPanel ? panel.thickness : parent.width - leftFloatingPadding - rightFloatingPadding
        height: verticalPanel ? parent.height - topFloatingPadding - bottomFloatingPadding : panel.thickness

        imagePath: containment?.plasmoid?.backgroundHints === PlasmaCore.Types.NoBackground ? "" : "widgets/panel-background"
    }
    KSvg.FrameSvgItem {
        id: floatingOpaqueItem
        visible: floatingness !== 0 && panelOpacity !== 0
        opacity: panelOpacity
        anchors.fill: floatingTranslucentItem
        imagePath: containment?.plasmoid?.backgroundHints === PlasmaCore.Types.NoBackground ? "" : "solid/widgets/panel-background"
    }
    KSvg.FrameSvgItem {
        id: opaqueItem
        visible: panelOpacity !== 0 && floatingness === 0
        opacity: panelOpacity
        enabledBorders: panel.enabledBorders
        anchors.fill: floatingTranslucentItem
        imagePath: containment?.plasmoid?.backgroundHints === PlasmaCore.Types.NoBackground ? "" : "solid/widgets/panel-background"
    }
    KSvg.FrameSvgItem {
        id: floatingShadow
        visible: !hasShadows
        z: -100
        imagePath: containment?.plasmoid?.backgroundHints === PlasmaCore.Types.NoBackground ? "" : "solid/widgets/panel-background"
        prefix: "shadow"
        anchors {
            fill: floatingTranslucentItem
            topMargin: -floatingShadow.margins.top
            leftMargin: -floatingShadow.margins.left
            rightMargin: -floatingShadow.margins.right
            bottomMargin: -floatingShadow.margins.bottom
        }
    }

    Keys.onEscapePressed: {
        root.parent.focus = false
    }

    property bool isOpaque: panel.opacityMode === Panel.Global.Opaque
    property bool isTransparent: panel.opacityMode === Panel.Global.Translucent
    property bool isAdaptive: panel.opacityMode === Panel.Global.Adaptive
    property bool floating: panel.floating
    property bool hasCompositing: KWindowSystem.isPlatformX11 ? KX11Extras.compositingActive : true
    readonly property bool screenCovered: touchingWindow && panel.visibilityMode == Panel.Global.NormalPanel
    property var stateTriggers: [floating, screenCovered, isOpaque, isAdaptive, isTransparent, hasCompositing, containment]
    onStateTriggersChanged: {
        let opaqueApplets = false
        let floatingApplets = false
        if ((!floating || screenCovered) && (isOpaque || (screenCovered && isAdaptive))) {
            panelOpacity = 1
            opaqueApplets = true
            floatingness = 0
        } else if ((!floating || screenCovered) && (isTransparent || (!screenCovered && isAdaptive))) {
            panelOpacity = 0
            floatingness = 0
        } else if ((floating && !screenCovered) && (isTransparent || isAdaptive)) {
            panelOpacity = 0
            floatingness = 1
            floatingApplets = true
        } else if (floating && !screenCovered && isOpaque) {
            panelOpacity = 1
            opaqueApplets = true
            floatingness = 1
            floatingApplets = true
        }
        if (!KWindowSystem.isPlatformWayland && !KX11Extras.compositingActive) {
            opaqueApplets = false
            panelOpacity = 0
        }
        // Not using panelOpacity to check as it has a NumberAnimation, and it will thus
        // be still read as the initial value here, before the animation starts.
        if (containment) {
            if (opaqueApplets) {
                containment.plasmoid.containmentDisplayHints |= PlasmaCore.Types.ContainmentPrefersOpaqueBackground
            } else {
                containment.plasmoid.containmentDisplayHints &= ~PlasmaCore.Types.ContainmentPrefersOpaqueBackground
            }
            if (floatingApplets) {
                containment.plasmoid.containmentDisplayHints |= PlasmaCore.Types.ContainmentPrefersFloatingApplets
            } else {
                containment.plasmoid.containmentDisplayHints &= ~PlasmaCore.Types.ContainmentPrefersFloatingApplets
            }
        }
    }

    function adjustPrefix() {
        if (!containment) {
            return "";
        }
        var pre;
        switch (containment.plasmoid.location) {
        case PlasmaCore.Types.LeftEdge:
            pre = "west";
            break;
        case PlasmaCore.Types.TopEdge:
            pre = "north";
            break;
        case PlasmaCore.Types.RightEdge:
            pre = "east";
            break;
        case PlasmaCore.Types.BottomEdge:
            pre = "south";
            break;
        default:
            pre = "";
            break;
        }
        translucentItem.prefix = opaqueItem.prefix = floatingTranslucentItem.prefix = floatingOpaqueItem.prefix = [pre, ""];
    }

    onContainmentChanged: {
        if (!containment) {
            return;
        }
        containment.parent = containmentParent;
        containment.visible = true;
        containment.anchors.fill = containmentParent;
        containment.plasmoid.locationChanged.connect(adjustPrefix);
        adjustPrefix();
    }

    Binding {
        target: panel
        property: "length"
        when: containment
        value: {
            if (!containment) {
                return;
            }
            if (verticalPanel) {
                return containment.Layout.preferredHeight
            } else {
                return containment.Layout.preferredWidth
            }
        }
        restoreMode: Binding.RestoreBinding
    }

    Binding {
        target: panel
        property: "backgroundHints"
        when: containment
        value: {
            if (!containment) {
                return;
            }

            return containment.plasmoid.backgroundHints;
        }
        restoreMode: Binding.RestoreBinding
    }

    KSvg.FrameSvgItem {
        x: root.verticalPanel || !panel.activeFocusItem
            ? 0
            : Math.max(panel.activeFocusItem.Kirigami.ScenePosition.x, panel.activeFocusItem.Kirigami.ScenePosition.x)
        y: root.verticalPanel && panel.activeFocusItem
            ? Math.max(panel.activeFocusItem.Kirigami.ScenePosition.y, panel.activeFocusItem.Kirigami.ScenePosition.y)
            : 0

        width: panel.activeFocusItem
            ? (root.verticalPanel ? root.width : Math.min(panel.activeFocusItem.width, panel.activeFocusItem.width))
            : 0
        height: panel.activeFocusItem
            ? (root.verticalPanel ?  Math.min(panel.activeFocusItem.height, panel.activeFocusItem.height) : root.height)
            : 0

        visible: panel.active && panel.activeFocusItem

        imagePath: "widgets/tabbar"
        prefix: {
            if (!root.containment) {
                return "";
            }
            var prefix = ""
            switch (root.containment.plasmoid.location) {
                case PlasmaCore.Types.LeftEdge:
                    prefix = "west-active-tab";
                    break;
                case PlasmaCore.Types.TopEdge:
                    prefix = "north-active-tab";
                    break;
                case PlasmaCore.Types.RightEdge:
                    prefix = "east-active-tab";
                    break;
                default:
                    prefix = "south-active-tab";
            }
            if (!hasElementPrefix(prefix)) {
                prefix = "active-tab";
            }
            return prefix;
        }
    }
    Item {
        id: containmentParent
        anchors.centerIn: isOpaque ? floatingOpaqueItem : floatingTranslucentItem
        width: root.verticalPanel ? panel.thickness : root.width - fixedLeftFloatingPadding - fixedRightFloatingPadding
        height: root.verticalPanel ? root.height - fixedBottomFloatingPadding - fixedTopFloatingPadding : panel.thickness
    }
}

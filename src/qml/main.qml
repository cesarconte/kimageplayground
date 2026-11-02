/*
    SPDX-FileCopyrightText: 2026 Cesar
    SPDX-License-Identifier: GPL-3.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.ApplicationWindow {
    id: rootWindow
    width: 1020
    height: 760
    minimumWidth: 840
    minimumHeight: 620
    visible: true
    title: i18n("KImagePlayground — Estudio Creativo de Ilustración")

    property bool conceptDrawerOpen: true
    property int selectedCategoryIndex: 1 // Start on "Sujetos" (1) since Styles are featured in the top bar

    readonly property var primaryStyles: [
        { label: "Animación 3D", icon: "media-playback-start-symbolic" },
        { label: "Acuarela suave", icon: "draw-brush" },
        { label: "Boceto a lápiz", icon: "draw-freehand" },
        { label: "Ilustración Vectorial", icon: "applications-graphics" },
        { label: "Pixel Art retro", icon: "games-config-custom" }
    ]

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.mediumSpacing

        // -------------------------------------------------------------
        // 1. Top Header: Branding, Primary Style Segmented Bar & Actions
        // -------------------------------------------------------------
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.mediumSpacing

            RowLayout {
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Icon {
                    source: "draw-brush"
                    implicitWidth: Kirigami.Units.iconSizes.medium
                    implicitHeight: Kirigami.Units.iconSizes.medium
                    color: Kirigami.Theme.highlightColor
                }

                QQC2.Label {
                    text: i18n("Image Playground")
                    font.bold: true
                    font.pixelSize: 15
                    color: Kirigami.Theme.textColor
                }
            }

            Item { Layout.fillWidth: true }

            // Segmented Primary Style Selector (macOS Image Playground Style Bar)
            Rectangle {
                implicitHeight: 34
                implicitWidth: styleRow.implicitWidth + 8
                radius: 17
                color: Kirigami.Theme.alternateBackgroundColor
                border.width: 1
                border.color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.14)

                Row {
                    id: styleRow
                    anchors.centerIn: parent
                    spacing: 4

                    Repeater {
                        model: rootWindow.primaryStyles

                        delegate: Rectangle {
                            id: stylePill
                            required property var modelData
                            readonly property bool isSelected: Playground.selectedConcepts.indexOf(stylePill.modelData.label) !== -1

                            height: 26
                            width: stylePillRow.implicitWidth + 16
                            radius: 13
                            color: isSelected
                                ? Kirigami.Theme.highlightColor
                                : (styleMouse.containsMouse
                                    ? Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.10)
                                    : "transparent")

                            RowLayout {
                                id: stylePillRow
                                anchors.centerIn: parent
                                spacing: 4

                                Kirigami.Icon {
                                    source: stylePill.modelData.icon
                                    implicitWidth: 14
                                    implicitHeight: 14
                                    color: stylePill.isSelected ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.disabledTextColor
                                }

                                QQC2.Label {
                                    text: stylePill.modelData.label
                                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                                    font.bold: stylePill.isSelected
                                    color: stylePill.isSelected ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                                }
                            }

                            MouseArea {
                                id: styleMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Playground.setPrimaryStyle(stylePill.modelData.label)
                            }
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }

            RowLayout {
                spacing: Kirigami.Units.smallSpacing

                QQC2.ToolButton {
                    icon.name: "folder-pictures-symbolic"
                    text: i18n("Galería")
                    display: QQC2.AbstractButton.TextBesideIcon
                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.text: i18n("Abrir carpeta de ilustraciones (~/.local/share/kimageplayground/gallery)")
                    onClicked: Playground.openGalleryFolder()
                }

                QQC2.ToolButton {
                    icon.name: "view-refresh-symbolic"
                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.text: i18n("Refrescar galería")
                    onClicked: Playground.refreshGallery()
                }
            }
        }

        // -------------------------------------------------------------
        // 2. Central Hero Canvas (Dominates the view, exactly like macOS)
        // -------------------------------------------------------------
        Rectangle {
            id: canvasFrame
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Kirigami.Units.mediumSpacing
            color: Kirigami.Theme.backgroundColor
            border.width: 1
            border.color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.12)
            clip: true

            // Subtle grid background texture
            Rectangle {
                anchors.fill: parent
                color: Kirigami.Theme.alternateBackgroundColor
                opacity: 0.35
            }

            // A) Generating Busy State
            ColumnLayout {
                anchors.centerIn: parent
                visible: Playground.isGenerating
                spacing: Kirigami.Units.largeSpacing

                QQC2.BusyIndicator {
                    Layout.alignment: Qt.AlignHCenter
                    running: Playground.isGenerating
                    implicitWidth: 48
                    implicitHeight: 48
                }

                QQC2.Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: i18n("Creando ilustración en Image Playground…")
                    color: Kirigami.Theme.textColor
                    font.bold: true
                    font.pixelSize: 14
                }
            }

            // B) Active Generated Artwork
            Item {
                id: imageContainer
                anchors.fill: parent
                anchors.margins: Kirigami.Units.mediumSpacing
                visible: !Playground.isGenerating && Playground.currentImagePath.length > 0

                Image {
                    id: mainArtwork
                    anchors.centerIn: parent
                    width: Math.min(parent.width, parent.height)
                    height: width
                    source: Playground.currentImagePath.length > 0 ? ("file://" + Playground.currentImagePath) : ""
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                }

                // Floating Action Capsule atop Artwork (macOS Quick Actions)
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: Kirigami.Units.smallSpacing
                    implicitHeight: 38
                    implicitWidth: floatingActionsRow.implicitWidth + 24
                    radius: 19
                    color: Kirigami.Theme.backgroundColor
                    border.width: 1
                    border.color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.18)

                    RowLayout {
                        id: floatingActionsRow
                        anchors.centerIn: parent
                        spacing: Kirigami.Units.smallSpacing

                        QQC2.ToolButton {
                            icon.name: "edit-copy-symbolic"
                            text: i18n("Copiar")
                            display: QQC2.AbstractButton.TextBesideIcon
                            QQC2.ToolTip.visible: hovered
                            QQC2.ToolTip.text: i18n("Copiar imagen al portapapeles")
                            onClicked: Playground.copyToClipboard(Playground.currentImagePath)
                        }

                        Rectangle {
                            implicitWidth: 1
                            implicitHeight: 18
                            color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.15)
                        }

                        QQC2.ToolButton {
                            icon.name: "transform-crop-and-resize"
                            text: i18n("Aislar Sticker")
                            display: QQC2.AbstractButton.TextBesideIcon
                            QQC2.ToolTip.visible: hovered
                            QQC2.ToolTip.text: i18n("Remover fondo y crear pegatina transparente")
                            onClicked: Playground.liftSubjectSticker(Playground.currentImagePath)
                        }

                        Rectangle {
                            implicitWidth: 1
                            implicitHeight: 18
                            color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.15)
                        }

                        QQC2.ToolButton {
                            icon.name: "document-save-symbolic"
                            text: i18n("Guardar")
                            display: QQC2.AbstractButton.TextBesideIcon
                            QQC2.ToolTip.visible: hovered
                            QQC2.ToolTip.text: i18n("Guardar copia en ~/Imágenes")
                            onClicked: Playground.saveToPictures(Playground.currentImagePath)
                        }
                    }
                }
            }

            // C) Empty Canvas Placeholder
            ColumnLayout {
                anchors.centerIn: parent
                visible: !Playground.isGenerating && Playground.currentImagePath.length === 0
                spacing: Kirigami.Units.mediumSpacing

                Kirigami.Icon {
                    Layout.alignment: Qt.AlignHCenter
                    source: "draw-brush"
                    implicitWidth: 56
                    implicitHeight: 56
                    color: Kirigami.Theme.disabledTextColor
                }

                QQC2.Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: i18n("Elige conceptos o describe una idea para empezar a crear")
                    color: Kirigami.Theme.disabledTextColor
                    font.pixelSize: 14
                    font.weight: Font.Medium
                }
            }
        }

        // -------------------------------------------------------------
        // 3. Creative Studio Drawer (Prompt, Active Chips & Categorized Picker)
        // -------------------------------------------------------------
        Rectangle {
            id: studioTray
            Layout.fillWidth: true
            implicitHeight: trayCol.implicitHeight + Kirigami.Units.mediumSpacing * 2
            radius: Kirigami.Units.mediumSpacing
            color: Kirigami.Theme.alternateBackgroundColor
            border.width: 1
            border.color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.12)

            ColumnLayout {
                id: trayCol
                anchors.fill: parent
                anchors.margins: Kirigami.Units.mediumSpacing
                spacing: Kirigami.Units.smallSpacing

                // 3.A. Active Concept Chips Row (Interactive tokens like Apple Intelligence)
                RowLayout {
                    Layout.fillWidth: true
                    visible: Playground.selectedConcepts.length > 0
                    spacing: Kirigami.Units.smallSpacing

                    QQC2.Label {
                        text: i18n("Conceptos activos:")
                        font.bold: true
                        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        color: Kirigami.Theme.textColor
                    }

                    QQC2.ScrollView {
                        Layout.fillWidth: true
                        implicitHeight: 30
                        clip: true

                        Row {
                            spacing: 6
                            anchors.verticalCenter: parent.verticalCenter

                            Repeater {
                                model: Playground.selectedConcepts

                                delegate: Rectangle {
                                    id: activeChip
                                    required property string modelData
                                    height: 26
                                    width: activeChipRow.implicitWidth + 16
                                    radius: 13
                                    color: Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.18)
                                    border.width: 1
                                    border.color: Kirigami.Theme.highlightColor

                                    RowLayout {
                                        id: activeChipRow
                                        anchors.centerIn: parent
                                        spacing: 4

                                        QQC2.Label {
                                            text: activeChip.modelData
                                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                                            font.bold: true
                                            color: Kirigami.Theme.textColor
                                        }

                                        Kirigami.Icon {
                                            source: "window-close-symbolic"
                                            implicitWidth: 12
                                            implicitHeight: 12
                                            color: Kirigami.Theme.disabledTextColor

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: Playground.removeConcept(activeChip.modelData)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    QQC2.ToolButton {
                        icon.name: "edit-clear-all-symbolic"
                        implicitWidth: 26
                        implicitHeight: 26
                        QQC2.ToolTip.visible: hovered
                        QQC2.ToolTip.text: i18n("Limpiar todos los conceptos")
                        onClicked: Playground.clearConcepts()
                    }
                }

                // 3.B. Unified Prompt Bar (Prompt text + Toggle concepts + Aspect Ratio + Generar)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    QQC2.Button {
                        icon.name: rootWindow.conceptDrawerOpen ? "arrow-down-symbolic" : "arrow-up-symbolic"
                        text: rootWindow.conceptDrawerOpen ? i18n("Ocultar conceptos") : i18n("Explorar conceptos")
                        highlighted: rootWindow.conceptDrawerOpen
                        onClicked: rootWindow.conceptDrawerOpen = !rootWindow.conceptDrawerOpen
                    }

                    QQC2.TextField {
                        id: customPromptInput
                        Layout.fillWidth: true
                        placeholderText: i18n("Detalles adicionales o descripción libre (opcional)…")
                        text: Playground.currentPromptText
                        color: Kirigami.Theme.textColor
                        font.pixelSize: 13
                        onTextChanged: Playground.currentPromptText = text
                        onAccepted: Playground.generateImage(ratioSelector.currentText)
                    }

                    QQC2.ComboBox {
                        id: ratioSelector
                        implicitWidth: 95
                        model: ["1:1", "16:9", "9:16"]
                    }

                    QQC2.Button {
                        icon.name: "sparkles-symbolic"
                        text: i18n("Generar")
                        highlighted: true
                        enabled: !Playground.isGenerating && (Playground.selectedConcepts.length > 0 || customPromptInput.text.trim().length > 0)
                        onClicked: Playground.generateImage(ratioSelector.currentText)
                    }
                }

                // 3.C. Categorized Concept Picker (Clean Tabs + Ample Flow pills without clipping)
                ColumnLayout {
                    Layout.fillWidth: true
                    visible: rootWindow.conceptDrawerOpen
                    spacing: Kirigami.Units.smallSpacing

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.10)
                    }

                    // Category Selector Tabs
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing

                        Repeater {
                            model: Playground.availableConcepts

                            delegate: Rectangle {
                                id: catTab
                                required property var modelData
                                required property int index
                                readonly property bool isSelected: rootWindow.selectedCategoryIndex === catTab.index

                                implicitHeight: 28
                                implicitWidth: tabRow.implicitWidth + 20
                                radius: 14
                                color: isSelected
                                    ? Kirigami.Theme.highlightColor
                                    : (tabMouse.containsMouse
                                        ? Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.08)
                                        : "transparent")
                                border.width: 1
                                border.color: isSelected
                                    ? Kirigami.Theme.highlightColor
                                    : Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.12)

                                RowLayout {
                                    id: tabRow
                                    anchors.centerIn: parent
                                    spacing: 4

                                    Kirigami.Icon {
                                        source: catTab.modelData.icon || "folder-symbolic"
                                        implicitWidth: 14
                                        implicitHeight: 14
                                        color: catTab.isSelected ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                                    }

                                    QQC2.Label {
                                        text: catTab.modelData.category
                                        font.bold: catTab.isSelected
                                        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                                        color: catTab.isSelected ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                                    }
                                }

                                MouseArea {
                                    id: tabMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: rootWindow.selectedCategoryIndex = catTab.index
                                }
                            }
                        }
                    }

                    // Concept Pills Flow (Never truncated, full comfort)
                    QQC2.ScrollView {
                        Layout.fillWidth: true
                        implicitHeight: Math.min(100, flowContainer.implicitHeight + 8)
                        clip: true

                        Flow {
                            id: flowContainer
                            width: parent.width
                            spacing: 8
                            padding: 4

                            Repeater {
                                model: (Playground.availableConcepts.length > rootWindow.selectedCategoryIndex && rootWindow.selectedCategoryIndex >= 0)
                                    ? Playground.availableConcepts[rootWindow.selectedCategoryIndex].items
                                    : []

                                delegate: Rectangle {
                                    id: conceptPill
                                    required property string modelData
                                    readonly property bool isSelected: Playground.selectedConcepts.indexOf(conceptPill.modelData) !== -1

                                    implicitHeight: 30
                                    implicitWidth: pillContentRow.implicitWidth + 22
                                    radius: 15
                                    color: isSelected
                                        ? Kirigami.Theme.highlightColor
                                        : (pillMouse.containsMouse
                                            ? Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.12)
                                            : Kirigami.Theme.backgroundColor)
                                    border.width: 1
                                    border.color: isSelected
                                        ? Kirigami.Theme.highlightColor
                                        : Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.16)

                                    RowLayout {
                                        id: pillContentRow
                                        anchors.centerIn: parent
                                        spacing: 4

                                        Kirigami.Icon {
                                            visible: conceptPill.isSelected
                                            source: "checkmark"
                                            implicitWidth: 12
                                            implicitHeight: 12
                                            color: Kirigami.Theme.highlightedTextColor
                                        }

                                        QQC2.Label {
                                            text: conceptPill.modelData
                                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                                            font.bold: conceptPill.isSelected
                                            color: conceptPill.isSelected ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                                        }
                                    }

                                    MouseArea {
                                        id: pillMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (conceptPill.isSelected) {
                                                Playground.removeConcept(conceptPill.modelData);
                                            } else {
                                                Playground.addConcept(conceptPill.modelData);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // -------------------------------------------------------------
        // 4. Bottom History Gallery Carousel
        // -------------------------------------------------------------
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 76
            radius: Kirigami.Units.mediumSpacing
            color: Kirigami.Theme.alternateBackgroundColor
            border.width: 1
            border.color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.12)

            RowLayout {
                anchors.fill: parent
                anchors.margins: Kirigami.Units.smallSpacing
                spacing: Kirigami.Units.smallSpacing

                QQC2.Label {
                    text: i18n("Historial (%1):", Playground.galleryImages.length)
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    font.bold: true
                    color: Kirigami.Theme.disabledTextColor
                }

                QQC2.Label {
                    visible: Playground.galleryImages.length === 0
                    text: i18n("Las ilustraciones creadas aparecerán aquí.")
                    font.italic: true
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    color: Kirigami.Theme.disabledTextColor
                }

                QQC2.ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    visible: Playground.galleryImages.length > 0

                    Row {
                        spacing: 8
                        anchors.verticalCenter: parent.verticalCenter

                        Repeater {
                            model: Playground.galleryImages

                            delegate: Rectangle {
                                id: thumbCard
                                required property var modelData
                                width: 56
                                height: 56
                                radius: 6
                                color: Kirigami.Theme.backgroundColor
                                border.width: Playground.currentImagePath === thumbCard.modelData.path ? 2 : 1
                                border.color: Playground.currentImagePath === thumbCard.modelData.path
                                    ? Kirigami.Theme.highlightColor
                                    : Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.14)

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    source: "file://" + thumbCard.modelData.path
                                    fillMode: Image.PreserveAspectCrop
                                    smooth: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Playground.selectImage(thumbCard.modelData.path)
                                }
                            }
                        }
                    }
                }
            }
        }

        // -------------------------------------------------------------
        // 5. Status Bar
        // -------------------------------------------------------------
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            QQC2.Label {
                Layout.fillWidth: true
                text: Playground.statusMessage
                color: Kirigami.Theme.disabledTextColor
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                elide: Text.ElideRight
            }
        }
    }
}

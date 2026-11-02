/*
    SPDX-FileCopyrightText: 2026 Cesar
    SPDX-License-Identifier: GPL-3.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Window {
    id: rootWindow
    width: 960
    height: 700
    visible: true
    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    title: "KImagePlayground"

    Rectangle {
        id: mainSurface
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        radius: Kirigami.Units.largeSpacing
        color: Kirigami.Theme.backgroundColor
        border.width: 1
        border.color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.18)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.mediumSpacing

            // Header Toolbar
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Icon {
                    source: "draw-brush"
                    implicitWidth: Kirigami.Units.iconSizes.medium
                    implicitHeight: Kirigami.Units.iconSizes.medium
                    color: Kirigami.Theme.highlightColor
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    QQC2.Label {
                        text: "KImagePlayground"
                        font.pixelSize: 17
                        font.bold: true
                        color: Kirigami.Theme.textColor
                    }

                    QQC2.Label {
                        text: "Estudio Creativo de Ilustración con Conceptos · Apple Intelligence"
                        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        color: Kirigami.Theme.disabledTextColor
                    }
                }

                QQC2.ToolButton {
                    icon.name: "folder-pictures-symbolic"
                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.text: "Abrir galería (~/.local/share/kimageplayground/gallery)"
                    onClicked: Playground.openGalleryFolder()
                }

                QQC2.ToolButton {
                    icon.name: "view-refresh-symbolic"
                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.text: "Refrescar galería"
                    onClicked: Playground.refreshGallery()
                }

                QQC2.ToolButton {
                    icon.name: "window-close-symbolic"
                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.text: "Cerrar"
                    onClicked: Qt.quit()
                }
            }

            // Active Concept Chips Tray
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                radius: Kirigami.Units.mediumSpacing
                color: Kirigami.Theme.alternateBackgroundColor
                border.width: 1
                border.color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.12)

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Kirigami.Units.mediumSpacing
                    anchors.rightMargin: Kirigami.Units.mediumSpacing
                    spacing: Kirigami.Units.smallSpacing

                    QQC2.Label {
                        text: "Conceptos activos:"
                        font.bold: true
                        color: Kirigami.Theme.textColor
                        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    }

                    QQC2.Label {
                        visible: Playground.selectedConcepts.length === 0
                        text: "(Ninguno seleccionado. Elige estilos o temas abajo)"
                        color: Kirigami.Theme.disabledTextColor
                        font.italic: true
                        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    }

                    QQC2.ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        visible: Playground.selectedConcepts.length > 0

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 6

                            Repeater {
                                model: Playground.selectedConcepts

                                delegate: Rectangle {
                                    id: chipPill
                                    required property string modelData
                                    height: 28
                                    width: chipRow.implicitWidth + 16
                                    radius: 14
                                    color: Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.20)
                                    border.width: 1
                                    border.color: Kirigami.Theme.highlightColor

                                    RowLayout {
                                        id: chipRow
                                        anchors.centerIn: parent
                                        spacing: 4

                                        QQC2.Label {
                                            text: chipPill.modelData
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
                                                onClicked: Playground.removeConcept(chipPill.modelData)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    QQC2.ToolButton {
                        visible: Playground.selectedConcepts.length > 0
                        icon.name: "edit-clear-all-symbolic"
                        QQC2.ToolTip.visible: hovered
                        QQC2.ToolTip.text: "Limpiar todos los conceptos"
                        onClicked: Playground.clearConcepts()
                    }
                }
            }

            // Main Studio Body: Concept Explorer (Left) & Canvas Preview (Right)
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Kirigami.Units.mediumSpacing

                // Left Panel: Concept Categories Accordion / Flow
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 3
                    radius: Kirigami.Units.mediumSpacing
                    color: Kirigami.Theme.alternateBackgroundColor
                    border.width: 1
                    border.color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.12)

                    QQC2.ScrollView {
                        anchors.fill: parent
                        anchors.margins: Kirigami.Units.mediumSpacing
                        clip: true

                        ColumnLayout {
                            width: parent.width
                            spacing: Kirigami.Units.mediumSpacing

                            Repeater {
                                model: Playground.availableConcepts

                                delegate: ColumnLayout {
                                    id: catCol
                                    required property var modelData
                                    Layout.fillWidth: true
                                    spacing: 6

                                    QQC2.Label {
                                        text: catCol.modelData.category
                                        font.bold: true
                                        font.pixelSize: 13
                                        color: Kirigami.Theme.highlightColor
                                    }

                                    Flow {
                                        Layout.fillWidth: true
                                        spacing: 6

                                        Repeater {
                                            model: catCol.modelData.items

                                            delegate: Rectangle {
                                                id: conceptBadge
                                                required property string modelData
                                                readonly property bool isSelected: Playground.selectedConcepts.indexOf(conceptBadge.modelData) !== -1

                                                height: 28
                                                width: badgeText.implicitWidth + 18
                                                radius: 14
                                                color: isSelected
                                                    ? Kirigami.Theme.highlightColor
                                                    : (badgeMouse.containsMouse
                                                        ? Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.12)
                                                        : Kirigami.Theme.backgroundColor)
                                                border.width: 1
                                                border.color: isSelected
                                                    ? Kirigami.Theme.highlightColor
                                                    : Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.14)

                                                QQC2.Label {
                                                    id: badgeText
                                                    anchors.centerIn: parent
                                                    text: conceptBadge.modelData
                                                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                                                    color: conceptBadge.isSelected ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                                                }

                                                MouseArea {
                                                    id: badgeMouse
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        if (conceptBadge.isSelected) {
                                                            Playground.removeConcept(conceptBadge.modelData)
                                                        } else {
                                                            Playground.addConcept(conceptBadge.modelData)
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
                }

                // Right Panel: Canvas & Action Controls
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 4
                    radius: Kirigami.Units.mediumSpacing
                    color: Kirigami.Theme.alternateBackgroundColor
                    border.width: 1
                    border.color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.12)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Kirigami.Units.mediumSpacing
                        spacing: Kirigami.Units.smallSpacing

                        // Prompt & Aspect ratio controls
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Kirigami.Units.smallSpacing

                            QQC2.TextField {
                                id: customPromptInput
                                Layout.fillWidth: true
                                placeholderText: "Detalles adicionales (opcional)..."
                                text: Playground.currentPromptText
                                color: Kirigami.Theme.textColor
                                font.pixelSize: 13
                                onTextChanged: Playground.currentPromptText = text
                                onAccepted: {
                                    Playground.generateImage(ratioSelector.currentText)
                                }
                            }

                            QQC2.ComboBox {
                                id: ratioSelector
                                implicitWidth: 95
                                model: ["1:1", "16:9", "9:16"]
                            }

                            QQC2.Button {
                                icon.name: "sparkles-symbolic"
                                text: "Generar"
                                highlighted: true
                                enabled: !Playground.isGenerating && (Playground.selectedConcepts.length > 0 || customPromptInput.text.trim().length > 0)
                                onClicked: Playground.generateImage(ratioSelector.currentText)
                            }
                        }

                        // Big Canvas Stage
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 8
                            color: Kirigami.Theme.backgroundColor
                            border.width: 1
                            border.color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.10)
                            clip: true

                            // Busy state
                            ColumnLayout {
                                anchors.centerIn: parent
                                visible: Playground.isGenerating
                                spacing: Kirigami.Units.mediumSpacing

                                QQC2.BusyIndicator {
                                    Layout.alignment: Qt.AlignHCenter
                                    running: Playground.isGenerating
                                }

                                QQC2.Label {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "Creando ilustración en Image Playground…"
                                    color: Kirigami.Theme.textColor
                                    font.bold: true
                                }
                            }

                            // Active Image
                            Image {
                                anchors.centerIn: parent
                                visible: !Playground.isGenerating && Playground.currentImagePath.length > 0
                                width: Math.min(parent.width - 20, parent.height - 20)
                                height: width
                                source: Playground.currentImagePath.length > 0 ? ("file://" + Playground.currentImagePath) : ""
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                            }

                            // Empty state
                            ColumnLayout {
                                anchors.centerIn: parent
                                visible: !Playground.isGenerating && Playground.currentImagePath.length === 0
                                spacing: Kirigami.Units.smallSpacing

                                Kirigami.Icon {
                                    Layout.alignment: Qt.AlignHCenter
                                    source: "draw-brush"
                                    implicitWidth: 48
                                    implicitHeight: 48
                                    color: Kirigami.Theme.disabledTextColor
                                }

                                QQC2.Label {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "Selecciona conceptos a la izquierda y pulsa «Generar»"
                                    color: Kirigami.Theme.disabledTextColor
                                }
                            }
                        }

                        // Canvas Action Bar
                        RowLayout {
                            Layout.fillWidth: true
                            visible: !Playground.isGenerating && Playground.currentImagePath.length > 0
                            spacing: Kirigami.Units.smallSpacing

                            QQC2.Button {
                                Layout.fillWidth: true
                                icon.name: "edit-copy-symbolic"
                                text: "Copiar imagen"
                                onClicked: Playground.copyToClipboard(Playground.currentImagePath)
                            }

                            QQC2.Button {
                                Layout.fillWidth: true
                                icon.name: "transform-crop-and-resize"
                                text: "Aislar Sujeto (Sticker)"
                                onClicked: Playground.liftSubjectSticker(Playground.currentImagePath)
                            }

                            QQC2.Button {
                                Layout.fillWidth: true
                                icon.name: "document-save-symbolic"
                                text: "Guardar en Imágenes"
                                onClicked: Playground.saveToPictures(Playground.currentImagePath)
                            }
                        }
                    }
                }
            }

            // Bottom Thumbnail Gallery Strip
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 82
                radius: Kirigami.Units.mediumSpacing
                color: Kirigami.Theme.alternateBackgroundColor
                border.width: 1
                border.color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.12)

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.smallSpacing
                    spacing: Kirigami.Units.smallSpacing

                    QQC2.Label {
                        text: "Historial (" + Playground.galleryImages.length + "):"
                        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        font.bold: true
                        color: Kirigami.Theme.disabledTextColor
                    }

                    QQC2.ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        Row {
                            spacing: 8
                            anchors.verticalCenter: parent.verticalCenter

                            Repeater {
                                model: Playground.galleryImages

                                delegate: Rectangle {
                                    id: thumbCard
                                    required property var modelData
                                    width: 62
                                    height: 62
                                    radius: 6
                                    color: Kirigami.Theme.backgroundColor
                                    border.width: 1
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

            // Status Bar
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
}

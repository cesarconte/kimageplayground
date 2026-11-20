/*
    SPDX-FileCopyrightText: 2026 Cesar
    SPDX-License-Identifier: GPL-3.0-or-later

    KImagePlayground — Estudio Creativo de Ilustración con IA local.
    Diseño Golden Gate / Liquid Glass (CachyOS.UI).
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

CachyWindow {
    id: rootWindow

    width: 1040
    height: 780
    minimumWidth: 840
    minimumHeight: 620
    visible: true
    title: CachyI18n.i18n("Image Playground — Estudio Creativo de Ilustración")

    showTrafficLights: true
    showTitleBarDivider: true
    showWindowFrame: true
    resizable: true
    cornerRadius: CachyTheme.radiusWindow
    contentPadded: true

    property bool conceptDrawerOpen: true
    property int selectedCategoryIndex: 1 // Iniciar en "Sujetos"

    readonly property var primaryStyles: [
        { label: "Animación 3D", icon: "media-playback-start-symbolic" },
        { label: "Acuarela suave", icon: "draw-brush" },
        { label: "Boceto a lápiz", icon: "draw-freehand" },
        { label: "Ilustración Vectorial", icon: "applications-graphics" },
        { label: "Pixel Art retro", icon: "games-config-custom" }
    ]

    // =========================================================================
    // CABECERA — IZQUIERDA: marca
    // =========================================================================
    headerLeading: [
        CachyIcon {
            anchors.verticalCenter: parent.verticalCenter
            name: "draw-brush"
            size: 18
            color: CachyTheme.accentColor
        }
    ]

    // =========================================================================
    // CABECERA — CENTRO: Selector de Estilo Primario (macOS Image Playground)
    // =========================================================================
    headerCenter: [
        Rectangle {
            id: styleBarBg
            anchors.centerIn: parent
            implicitHeight: 34
            implicitWidth: styleRow.implicitWidth + 8
            radius: 17
            color: CachyPalette.isDark ? Qt.rgba(0, 0, 0, 0.28) : Qt.rgba(0, 0, 0, 0.08)
            border.width: 1
            border.color: CachyPalette.specularBorder

            Row {
                id: styleRow
                anchors.centerIn: parent
                spacing: 2

                Repeater {
                    model: rootWindow.primaryStyles

                    delegate: Rectangle {
                        id: stylePill
                        required property var modelData
                        readonly property bool isSelected: Playground.selectedConcepts.indexOf(stylePill.modelData.label) !== -1

                        height: 28
                        width: stylePillRow.implicitWidth + 20
                        radius: 14
                        color: isSelected
                            ? CachyTheme.accentColor
                            : (styleMouse.containsMouse
                                ? CachyTheme.cardBackgroundHover
                                : "transparent")

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }

                        RowLayout {
                            id: stylePillRow
                            anchors.centerIn: parent
                            spacing: 5

                            CachyIcon {
                                name: stylePill.modelData.icon
                                size: 14
                                color: stylePill.isSelected ? "#FFFFFF" : CachyTheme.textMuted
                            }

                            CachyLabel {
                                text: stylePill.modelData.label
                                font.pixelSize: 12
                                font.bold: stylePill.isSelected
                                color: stylePill.isSelected ? "#FFFFFF" : CachyPalette.text
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
    ]

    // =========================================================================
    // CABECERA — DERECHA: Acciones
    // =========================================================================
    headerActions: [
        RowLayout {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            CachyToolbarButton {
                iconName: "folder-pictures-symbolic"
                text: CachyI18n.i18n("Galería")
                tooltipText: CachyI18n.i18n("Abrir carpeta de ilustraciones (~/.local/share/kimageplayground/gallery)")
                onClicked: Playground.openGalleryFolder()
            }

            CachyToolbarButton {
                iconName: "view-refresh-symbolic"
                tooltipText: CachyI18n.i18n("Refrescar galería")
                onClicked: Playground.refreshGallery()
            }
        }
    ]

    // =========================================================================
    // CONTENIDO PRINCIPAL
    // =========================================================================
    contentData: [
        ColumnLayout {
            anchors.fill: parent
            spacing: CachyTheme.spacingMedium

            // -----------------------------------------------------------------
            // 1. Lienzo Central Hero
            // -----------------------------------------------------------------
            CachyCard {
                id: canvasCard
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 0
                clip: true

                contentItem: Item {
                    anchors.fill: parent

                    // Estado: Generando con IA
                    ColumnLayout {
                        anchors.centerIn: parent
                        visible: Playground.isGenerating
                        spacing: CachyTheme.spacingMedium

                        CachyBusyIndicator {
                            Layout.alignment: Qt.AlignHCenter
                            running: Playground.isGenerating
                            size: 44
                        }

                        CachyLabel {
                            Layout.alignment: Qt.AlignHCenter
                            text: CachyI18n.i18n("Creando ilustración en Image Playground…")
                            color: CachyPalette.text
                            font.bold: true
                            font.pixelSize: 14
                        }
                    }

                    // Estado: Ilustración generada
                    Item {
                        id: imageContainer
                        anchors.fill: parent
                        anchors.margins: CachyTheme.spacingMedium
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

                        // Cápsula de acciones rápidas flotante (macOS Liquid Glass)
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottomMargin: CachyTheme.spacingSmall
                            height: 40
                            width: floatingActionsRow.implicitWidth + 24
                            radius: 20
                            color: CachyPalette.isDark ? Qt.rgba(0.12, 0.12, 0.12, 0.88) : Qt.rgba(1, 1, 1, 0.88)
                            border.width: 1
                            border.color: CachyPalette.specularBorder

                            RowLayout {
                                id: floatingActionsRow
                                anchors.centerIn: parent
                                spacing: 6

                                CachyToolbarButton {
                                    iconName: "edit-copy-symbolic"
                                    text: CachyI18n.i18n("Copiar")
                                    tooltipText: CachyI18n.i18n("Copiar imagen al portapapeles")
                                    onClicked: Playground.copyToClipboard(Playground.currentImagePath)
                                }

                                Rectangle {
                                    Layout.preferredWidth: 1
                                    Layout.preferredHeight: 18
                                    Layout.alignment: Qt.AlignVCenter
                                    color: CachyPalette.specularBorder
                                }

                                CachyToolbarButton {
                                    iconName: "transform-crop-and-resize"
                                    text: CachyI18n.i18n("Aislar Sticker")
                                    tooltipText: CachyI18n.i18n("Remover fondo y crear pegatina transparente")
                                    onClicked: Playground.liftSubjectSticker(Playground.currentImagePath)
                                }

                                Rectangle {
                                    Layout.preferredWidth: 1
                                    Layout.preferredHeight: 18
                                    Layout.alignment: Qt.AlignVCenter
                                    color: CachyPalette.specularBorder
                                }

                                CachyToolbarButton {
                                    iconName: "document-save-symbolic"
                                    text: CachyI18n.i18n("Guardar")
                                    tooltipText: CachyI18n.i18n("Guardar copia en ~/Imágenes")
                                    onClicked: Playground.saveToPictures(Playground.currentImagePath)
                                }
                            }
                        }
                    }

                    // Estado: Vacío
                    ColumnLayout {
                        anchors.centerIn: parent
                        visible: !Playground.isGenerating && Playground.currentImagePath.length === 0
                        spacing: CachyTheme.spacingMedium

                        CachyIcon {
                            Layout.alignment: Qt.AlignHCenter
                            name: "draw-brush"
                            size: 56
                            color: CachyTheme.textMuted
                        }

                        CachyLabel {
                            Layout.alignment: Qt.AlignHCenter
                            text: CachyI18n.i18n("Elige conceptos o describe una idea para empezar a crear")
                            color: CachyTheme.textMuted
                            font.pixelSize: 14
                            font.weight: Font.Medium
                        }
                    }
                }
            }

            // -----------------------------------------------------------------
            // 2. Estudio Creativo (Prompt, Chips Activos y Carrusel de Conceptos)
            // -----------------------------------------------------------------
            CachyCard {
                id: studioCard
                Layout.fillWidth: true
                Layout.minimumWidth: 0

                contentItem: ColumnLayout {
                    spacing: CachyTheme.spacingSmall

                    // 2.A. Chips de Conceptos Activos
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        visible: Playground.selectedConcepts.length > 0
                        spacing: CachyTheme.spacingSmall

                        CachyLabel {
                            text: CachyI18n.i18n("Conceptos:")
                            font.bold: true
                            font.pixelSize: 12
                            color: CachyPalette.text
                        }

                        Flickable {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            height: 30
                            contentWidth: activeChipsRow.implicitWidth
                            clip: true
                            boundsBehavior: Flickable.StopAtBounds

                            Row {
                                id: activeChipsRow
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
                                        color: CachyTheme.withAlpha(CachyTheme.accentColor, 0.18)
                                        border.width: 1
                                        border.color: CachyTheme.accentColor

                                        RowLayout {
                                            id: activeChipRow
                                            anchors.centerIn: parent
                                            spacing: 4

                                            CachyLabel {
                                                text: activeChip.modelData
                                                font.pixelSize: 11
                                                font.bold: true
                                                color: CachyPalette.text
                                            }

                                            CachyIcon {
                                                name: "window-close-symbolic"
                                                size: 12
                                                color: CachyTheme.textMuted

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

                        CachyToolbarButton {
                            iconName: "edit-clear-all-symbolic"
                            tooltipText: CachyI18n.i18n("Limpiar todos los conceptos")
                            onClicked: Playground.clearConcepts()
                        }
                    }

                    // 2.B. Barra de Prompt Unificada
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        spacing: 8

                        CachyButton {
                            iconName: rootWindow.conceptDrawerOpen ? "arrow-down-symbolic" : "arrow-up-symbolic"
                            text: rootWindow.conceptDrawerOpen ? CachyI18n.i18n("Ocultar conceptos") : CachyI18n.i18n("Explorar conceptos")
                            onClicked: rootWindow.conceptDrawerOpen = !rootWindow.conceptDrawerOpen
                        }

                        CachyTextField {
                            id: customPromptInput
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            placeholderText: CachyI18n.i18n("Detalles adicionales o descripción libre (opcional)…")
                            text: Playground.currentPromptText
                            font.pixelSize: 13
                            onTextChanged: Playground.currentPromptText = text
                            onAccepted: Playground.generateImage(ratioSelector.currentText)
                        }

                        CachyComboBox {
                            id: ratioSelector
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 32
                            model: ["1:1", "16:9", "9:16"]
                        }

                        CachyButton {
                            iconName: "sparkles-symbolic"
                            text: CachyI18n.i18n("Generar")
                            primary: true
                            enabled: !Playground.isGenerating && (Playground.selectedConcepts.length > 0 || customPromptInput.text.trim().length > 0)
                            onClicked: Playground.generateImage(ratioSelector.currentText)
                        }
                    }

                    // 2.C. Carrusel Horizontal de Conceptos
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        visible: rootWindow.conceptDrawerOpen
                        spacing: CachyTheme.spacingSmall

                        CachyDivider {}

                        // Pestañas de categorías
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            spacing: 6

                            Repeater {
                                model: Playground.availableConcepts

                                delegate: Rectangle {
                                    id: catTab
                                    required property var modelData
                                    required property int index
                                    readonly property bool isSelected: rootWindow.selectedCategoryIndex === catTab.index

                                    height: 28
                                    width: tabRow.implicitWidth + 20
                                    radius: 14
                                    color: isSelected
                                        ? CachyTheme.accentColor
                                        : (tabMouse.containsMouse
                                            ? CachyTheme.cardBackgroundHover
                                            : "transparent")
                                    border.width: 1
                                    border.color: isSelected
                                        ? CachyTheme.accentColor
                                        : CachyPalette.specularBorder

                                    Behavior on color {
                                        ColorAnimation { duration: 150 }
                                    }

                                    RowLayout {
                                        id: tabRow
                                        anchors.centerIn: parent
                                        spacing: 4

                                        CachyIcon {
                                            name: catTab.modelData.icon || "folder-symbolic"
                                            size: 14
                                            color: catTab.isSelected ? "#FFFFFF" : CachyTheme.textMuted
                                        }

                                        CachyLabel {
                                            text: catTab.modelData.category
                                            font.bold: catTab.isSelected
                                            font.pixelSize: 12
                                            color: catTab.isSelected ? "#FFFFFF" : CachyPalette.text
                                        }
                                    }

                                    MouseArea {
                                        id: tabMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            rootWindow.selectedCategoryIndex = catTab.index;
                                            conceptListView.contentX = 0;
                                        }
                                    }
                                }
                            }

                            Item { Layout.fillWidth: true }
                        }

                        // Carrusel horizontal de píldoras
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            spacing: 4

                            CachyToolbarButton {
                                iconName: "go-previous-symbolic"
                                enabled: conceptListView.contentX > 0
                                tooltipText: CachyI18n.i18n("Anterior")
                                onClicked: {
                                    conceptListView.contentX = Math.max(0, conceptListView.contentX - 280);
                                }
                            }

                            ListView {
                                id: conceptListView
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                height: 36
                                orientation: ListView.Horizontal
                                spacing: 8
                                clip: true
                                boundsBehavior: Flickable.StopAtBounds
                                flickableDirection: Flickable.HorizontalFlick

                                Behavior on contentX {
                                    NumberAnimation { duration: 220; easing.type: Easing.OutQuad }
                                }

                                model: (Playground.availableConcepts.length > rootWindow.selectedCategoryIndex && rootWindow.selectedCategoryIndex >= 0)
                                    ? Playground.availableConcepts[rootWindow.selectedCategoryIndex].items
                                    : []

                                delegate: Rectangle {
                                    id: conceptPill
                                    required property string modelData
                                    readonly property bool isSelected: Playground.selectedConcepts.indexOf(conceptPill.modelData) !== -1

                                    height: 30
                                    width: pillContentRow.implicitWidth + 24
                                    radius: 15
                                    color: isSelected
                                        ? CachyTheme.accentColor
                                        : (pillMouse.containsMouse
                                            ? CachyTheme.cardBackgroundHover
                                            : CachyTheme.cardBackground)
                                    border.width: 1
                                    border.color: isSelected
                                        ? CachyTheme.accentColor
                                        : CachyPalette.specularBorder

                                    Behavior on color {
                                        ColorAnimation { duration: 150 }
                                    }

                                    RowLayout {
                                        id: pillContentRow
                                        anchors.centerIn: parent
                                        spacing: 6

                                        CachyIcon {
                                            visible: conceptPill.isSelected
                                            name: "checkmark"
                                            size: 12
                                            color: "#FFFFFF"
                                        }

                                        CachyLabel {
                                            text: conceptPill.modelData
                                            font.pixelSize: 12
                                            font.bold: conceptPill.isSelected
                                            color: conceptPill.isSelected ? "#FFFFFF" : CachyPalette.text
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

                            CachyToolbarButton {
                                iconName: "go-next-symbolic"
                                enabled: (conceptListView.contentWidth > conceptListView.width) && (conceptListView.contentX + conceptListView.width < conceptListView.contentWidth - 2)
                                tooltipText: CachyI18n.i18n("Siguiente")
                                onClicked: {
                                    conceptListView.contentX = Math.min(conceptListView.contentWidth - conceptListView.width, conceptListView.contentX + 280);
                                }
                            }
                        }
                    }
                }
            }

            // -----------------------------------------------------------------
            // 3. Carrusel de Historial de Galería (macOS)
            // -----------------------------------------------------------------
            CachyCard {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                visible: Playground.galleryImages.length > 0
                Layout.preferredHeight: 80

                contentItem: RowLayout {
                    spacing: CachyTheme.spacingSmall

                    CachyLabel {
                        text: CachyI18n.i18n("Historial (%1):", Playground.galleryImages.length)
                        font.pixelSize: 12
                        font.bold: true
                        color: CachyTheme.textMuted
                    }

                    Flickable {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        Layout.fillHeight: true
                        contentWidth: thumbsRow.implicitWidth
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds

                        Row {
                            id: thumbsRow
                            spacing: 8
                            anchors.verticalCenter: parent.verticalCenter

                            Repeater {
                                model: Playground.galleryImages

                                delegate: Rectangle {
                                    id: thumbCard
                                    required property var modelData
                                    width: 56
                                    height: 56
                                    radius: 8
                                    color: "transparent"
                                    border.width: Playground.currentImagePath === thumbCard.modelData.path ? 2 : 1
                                    border.color: Playground.currentImagePath === thumbCard.modelData.path
                                        ? CachyTheme.accentColor
                                        : CachyPalette.specularBorder
                                    clip: true

                                    Image {
                                        anchors.fill: parent
                                        anchors.margins: 2
                                        source: "file://" + thumbCard.modelData.path
                                        fillMode: Image.PreserveAspectCrop
                                        smooth: true
                                    }

                                    MouseArea {
                                        id: thumbMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: Playground.selectImage(thumbCard.modelData.path)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // -----------------------------------------------------------------
            // 4. Barra de Estado
            // -----------------------------------------------------------------
            CachyDivider {}

            CachyLabel {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                text: Playground.statusMessage
                color: CachyTheme.textMuted
                font.pixelSize: 11
                elide: Text.ElideRight
            }
        }
    ]
}

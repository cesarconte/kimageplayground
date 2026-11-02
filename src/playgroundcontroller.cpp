/*
    SPDX-FileCopyrightText: 2026 Cesar
    SPDX-License-Identifier: GPL-3.0-or-later
*/

#include "playgroundcontroller.h"

#include <QClipboard>
#include <QDateTime>
#include <QDesktopServices>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QGuiApplication>
#include <QImage>
#include <QProcess>
#include <QRandomGenerator>
#include <QStandardPaths>
#include <QUrl>
#include <QUrlQuery>

PlaygroundController::PlaygroundController(QObject *parent)
    : QObject(parent)
    , m_nam(new QNetworkAccessManager(this))
{
    initStorage();
    loadAvailableConcepts();
    refreshGallery();
    m_statusMessage = QStringLiteral("Image Playground listo. Selecciona conceptos o escribe una descripción.");
}

bool PlaygroundController::isGenerating() const
{
    return m_isGenerating;
}

QString PlaygroundController::statusMessage() const
{
    return m_statusMessage;
}

QString PlaygroundController::currentImagePath() const
{
    return m_currentImagePath;
}

QString PlaygroundController::currentPromptText() const
{
    return m_currentPromptText;
}

void PlaygroundController::setCurrentPromptText(const QString &text)
{
    if (m_currentPromptText != text) {
        m_currentPromptText = text;
        Q_EMIT currentPromptTextChanged();
    }
}

QStringList PlaygroundController::selectedConcepts() const
{
    return m_selectedConcepts;
}

QVariantList PlaygroundController::galleryImages() const
{
    return m_galleryImages;
}

QVariantList PlaygroundController::availableConcepts() const
{
    return m_availableConcepts;
}

void PlaygroundController::initStorage()
{
    const QString dataPath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);
    m_storageDir = dataPath + QStringLiteral("/kimageplayground/gallery");
    m_cacheDir = dataPath + QStringLiteral("/kimageplayground/cache");

    QDir().mkpath(m_storageDir);
    QDir().mkpath(m_cacheDir);
}

void PlaygroundController::loadAvailableConcepts()
{
    m_availableConcepts = QVariantList{
        QVariantMap{
            {QStringLiteral("category"), QStringLiteral("Estilos")},
            {QStringLiteral("icon"), QStringLiteral("draw-brush-symbolic")},
            {QStringLiteral("items"), QStringList{
                QStringLiteral("Animación 3D"),
                QStringLiteral("Acuarela suave"),
                QStringLiteral("Boceto a lápiz"),
                QStringLiteral("Ilustración Vectorial"),
                QStringLiteral("Pixel Art retro"),
                QStringLiteral("Cyberpunk Neón"),
                QStringLiteral("Fotografía Cinematográfica"),
                QStringLiteral("Anime / Studio Ghibli")
            }}
        },
        QVariantMap{
            {QStringLiteral("category"), QStringLiteral("Sujetos")},
            {QStringLiteral("icon"), QStringLiteral("user-identity-symbolic")},
            {QStringLiteral("items"), QStringList{
                QStringLiteral("Robot explorador"),
                QStringLiteral("Gato con capa"),
                QStringLiteral("Castillo flotante"),
                QStringLiteral("Coche clásico volante"),
                QStringLiteral("Astronauta en bicicleta"),
                QStringLiteral("Dragón de cristal"),
                QStringLiteral("Café acogedor"),
                QStringLiteral("Zorro samurai")
            }}
        },
        QVariantMap{
            {QStringLiteral("category"), QStringLiteral("Entornos")},
            {QStringLiteral("icon"), QStringLiteral("tag-places-symbolic")},
            {QStringLiteral("items"), QStringList{
                QStringLiteral("Playa al atardecer"),
                QStringLiteral("Ciudad futurista lluviosa"),
                QStringLiteral("Bosque místico con luciérnagas"),
                QStringLiteral("Nebulosa en el espacio profundo"),
                QStringLiteral("Montañas nevadas al alba"),
                QStringLiteral("Jardín japonés zen")
            }}
        },
        QVariantMap{
            {QStringLiteral("category"), QStringLiteral("Iluminación & Clima")},
            {QStringLiteral("icon"), QStringLiteral("flashlight-on-symbolic")},
            {QStringLiteral("items"), QStringList{
                QStringLiteral("Hora dorada (Golden Hour)"),
                QStringLiteral("Luces de neón cyberpunk"),
                QStringLiteral("Luz suave de estudio"),
                QStringLiteral("Bioluminiscencia azul"),
                QStringLiteral("Niebla etérea")
            }}
        }
    };
    Q_EMIT availableConceptsChanged();
}

void PlaygroundController::setPrimaryStyle(const QString &styleName)
{
    QStringList styleItems;
    for (const auto &catVal : m_availableConcepts) {
        const QVariantMap cat = catVal.toMap();
        if (cat.value(QStringLiteral("category")).toString() == QStringLiteral("Estilos")) {
            styleItems = cat.value(QStringLiteral("items")).toStringList();
            break;
        }
    }

    bool changed = false;
    for (const QString &st : styleItems) {
        if (m_selectedConcepts.removeAll(st) > 0) {
            changed = true;
        }
    }
    if (!styleName.trimmed().isEmpty()) {
        m_selectedConcepts.prepend(styleName.trimmed());
        changed = true;
    }
    if (changed) {
        Q_EMIT selectedConceptsChanged();
        m_statusMessage = QStringLiteral("Estilo establecido: ") + styleName;
        Q_EMIT statusMessageChanged();
    }
}

void PlaygroundController::addConcept(const QString &conceptName)
{
    if (!conceptName.trimmed().isEmpty() && !m_selectedConcepts.contains(conceptName.trimmed())) {
        m_selectedConcepts.append(conceptName.trimmed());
        Q_EMIT selectedConceptsChanged();
        m_statusMessage = QStringLiteral("Concepto añadido: ") + conceptName.trimmed();
        Q_EMIT statusMessageChanged();
    }
}

void PlaygroundController::removeConcept(const QString &conceptName)
{
    if (m_selectedConcepts.removeOne(conceptName)) {
        Q_EMIT selectedConceptsChanged();
        m_statusMessage = QStringLiteral("Concepto eliminado.");
        Q_EMIT statusMessageChanged();
    }
}

void PlaygroundController::clearConcepts()
{
    m_selectedConcepts.clear();
    Q_EMIT selectedConceptsChanged();
    m_statusMessage = QStringLiteral("Conceptos limpiados.");
    Q_EMIT statusMessageChanged();
}

void PlaygroundController::generateImage(const QString &aspectRatio)
{
    if (m_isGenerating) {
        return;
    }

    QStringList parts = m_selectedConcepts;
    if (!m_currentPromptText.trimmed().isEmpty()) {
        parts.append(m_currentPromptText.trimmed());
    }

    if (parts.isEmpty()) {
        m_statusMessage = QStringLiteral("Selecciona al menos un concepto o escribe una descripción.");
        Q_EMIT statusMessageChanged();
        return;
    }

    m_isGenerating = true;
    Q_EMIT generatingChanged();

    const QString fullPrompt = parts.join(QStringLiteral(", ")) + QStringLiteral(", beautiful composition, highly detailed, masterpieces, 8k resolution");
    m_statusMessage = QStringLiteral("Generando en Playground: «") + parts.join(QStringLiteral(" + ")) + QStringLiteral("»...");
    Q_EMIT statusMessageChanged();

    int width = 512;
    int height = 512;
    if (aspectRatio == QLatin1String("16:9")) {
        width = 800;
        height = 450;
    } else if (aspectRatio == QLatin1String("9:16")) {
        width = 450;
        height = 800;
    }

    const quint32 seed = QRandomGenerator::global()->generate();
    const QString encodedPrompt = QString::fromUtf8(QUrl::toPercentEncoding(fullPrompt));
    QUrl url(QStringLiteral("https://image.pollinations.ai/prompt/") + encodedPrompt);
    QUrlQuery query;
    query.addQueryItem(QStringLiteral("width"), QString::number(width));
    query.addQueryItem(QStringLiteral("height"), QString::number(height));
    query.addQueryItem(QStringLiteral("nologo"), QStringLiteral("true"));
    query.addQueryItem(QStringLiteral("seed"), QString::number(seed));
    url.setQuery(query);

    QNetworkRequest request(url);
    request.setAttribute(QNetworkRequest::User, parts.join(QStringLiteral(", ")));
    QNetworkReply *reply = m_nam->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        onDownloadFinished(reply);
    });
}

void PlaygroundController::onDownloadFinished(QNetworkReply *reply)
{
    m_isGenerating = false;
    Q_EMIT generatingChanged();

    if (reply->error() != QNetworkReply::NoError) {
        m_statusMessage = QStringLiteral("Error al generar imagen: ") + reply->errorString();
        Q_EMIT statusMessageChanged();
        reply->deleteLater();
        return;
    }

    const QByteArray data = reply->readAll();
    const QString prompt = reply->request().attribute(QNetworkRequest::User).toString();
    reply->deleteLater();

    if (data.isEmpty()) {
        m_statusMessage = QStringLiteral("Respuesta vacía del servidor.");
        Q_EMIT statusMessageChanged();
        return;
    }

    const QString timeTag = QDateTime::currentDateTime().toString(QStringLiteral("yyyyMMdd_hhmmss"));
    const QString finalPath = m_storageDir + QStringLiteral("/playground_%1.jpg").arg(timeTag);

    QFile file(finalPath);
    if (!file.open(QIODevice::WriteOnly)) {
        m_statusMessage = QStringLiteral("No se pudo guardar la imagen generada.");
        Q_EMIT statusMessageChanged();
        return;
    }
    file.write(data);
    file.close();

    m_currentImagePath = finalPath;
    Q_EMIT currentImagePathChanged();

    refreshGallery();

    m_statusMessage = QStringLiteral("¡Imagen generada con éxito!");
    Q_EMIT statusMessageChanged();
    Q_EMIT imageGenerated(finalPath);
}

void PlaygroundController::selectImage(const QString &imagePath)
{
    if (QFile::exists(imagePath)) {
        m_currentImagePath = imagePath;
        Q_EMIT currentImagePathChanged();
        m_statusMessage = QStringLiteral("Imagen seleccionada.");
        Q_EMIT statusMessageChanged();
    }
}

void PlaygroundController::copyToClipboard(const QString &imagePath)
{
    if (!QFile::exists(imagePath)) {
        return;
    }

    QImage img(imagePath);
    if (!img.isNull()) {
        QGuiApplication::clipboard()->setImage(img);
    }

    QProcess wlProc;
    wlProc.setStandardInputFile(imagePath);
    wlProc.start(QStringLiteral("wl-copy"), {QStringLiteral("--type"), QStringLiteral("image/png")});
    wlProc.waitForFinished(1000);

    m_statusMessage = QStringLiteral("Imagen copiada al portapapeles de Wayland.");
    Q_EMIT statusMessageChanged();
}

void PlaygroundController::saveToPictures(const QString &imagePath)
{
    if (!QFile::exists(imagePath)) {
        return;
    }

    const QString picsDir = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation) + QStringLiteral("/ImagePlayground");
    QDir().mkpath(picsDir);

    const QFileInfo fi(imagePath);
    const QString destPath = picsDir + QStringLiteral("/") + fi.fileName();
    QFile::copy(imagePath, destPath);

    m_statusMessage = QStringLiteral("Guardada en Imágenes/ImagePlayground/") + fi.fileName();
    Q_EMIT statusMessageChanged();
}

void PlaygroundController::liftSubjectSticker(const QString &imagePath)
{
    if (!QFile::exists(imagePath)) {
        return;
    }

    const QString homeDir = QDir::homePath();
    const QString liftSubjectBin = homeDir + QStringLiteral("/.local/bin/kliftsubject");

    if (QFile::exists(liftSubjectBin)) {
        m_statusMessage = QStringLiteral("Extrayendo sujeto con KLiftSubject (IA local)...");
        Q_EMIT statusMessageChanged();

        QProcess proc;
        proc.start(liftSubjectBin, {QStringLiteral("--sticker"), imagePath});
        if (proc.waitForFinished(20000)) {
            const QString stickerVariant = imagePath.left(imagePath.lastIndexOf(QLatin1Char('.'))) + QStringLiteral("-sticker.png");
            if (QFile::exists(stickerVariant)) {
                copyToClipboard(stickerVariant);
                m_currentImagePath = stickerVariant;
                Q_EMIT currentImagePathChanged();
                refreshGallery();
                m_statusMessage = QStringLiteral("¡Sujeto aislado con éxito y copiado al portapapeles!");
                Q_EMIT statusMessageChanged();
                return;
            }
        }
    }

    m_statusMessage = QStringLiteral("KLiftSubject no disponible para extraer sujeto.");
    Q_EMIT statusMessageChanged();
}

void PlaygroundController::deleteFromGallery(const QString &imagePath)
{
    if (QFile::exists(imagePath)) {
        QFile::remove(imagePath);
        refreshGallery();
        if (m_currentImagePath == imagePath) {
            m_currentImagePath.clear();
            Q_EMIT currentImagePathChanged();
        }
        m_statusMessage = QStringLiteral("Imagen eliminada de la galería.");
        Q_EMIT statusMessageChanged();
    }
}

void PlaygroundController::openGalleryFolder()
{
    QDesktopServices::openUrl(QUrl::fromLocalFile(m_storageDir));
}

void PlaygroundController::refreshGallery()
{
    m_galleryImages.clear();
    QDir dir(m_storageDir, QStringLiteral("*.jpg *.png"), QDir::Time | QDir::Reversed, QDir::Files);
    const QFileInfoList files = dir.entryInfoList();
    for (int i = 0; i < files.size() && i < 40; ++i) {
        const QFileInfo &fi = files.at(i);
        QVariantMap item;
        item[QStringLiteral("path")] = fi.absoluteFilePath();
        item[QStringLiteral("fileName")] = fi.fileName();
        item[QStringLiteral("fileSizeText")] = QString(QString::number(fi.size() / 1024) + QStringLiteral(" KB"));
        m_galleryImages.append(item);
    }
    Q_EMIT galleryImagesChanged();
}

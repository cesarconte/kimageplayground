/*
    SPDX-FileCopyrightText: 2026 Cesar
    SPDX-License-Identifier: GPL-3.0-or-later
*/

#pragma once

#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariantList>
#include <QNetworkAccessManager>
#include <QNetworkReply>

class PlaygroundController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isGenerating READ isGenerating NOTIFY generatingChanged)
    Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusMessageChanged)
    Q_PROPERTY(QString currentImagePath READ currentImagePath NOTIFY currentImagePathChanged)
    Q_PROPERTY(QString currentPromptText READ currentPromptText WRITE setCurrentPromptText NOTIFY currentPromptTextChanged)
    Q_PROPERTY(QStringList selectedConcepts READ selectedConcepts NOTIFY selectedConceptsChanged)
    Q_PROPERTY(QVariantList galleryImages READ galleryImages NOTIFY galleryImagesChanged)
    Q_PROPERTY(QVariantList availableConcepts READ availableConcepts NOTIFY availableConceptsChanged)

public:
    explicit PlaygroundController(QObject *parent = nullptr);
    ~PlaygroundController() override = default;

    bool isGenerating() const;
    QString statusMessage() const;
    QString currentImagePath() const;
    QString currentPromptText() const;
    void setCurrentPromptText(const QString &text);
    QStringList selectedConcepts() const;
    QVariantList galleryImages() const;
    QVariantList availableConcepts() const;

    Q_INVOKABLE void addConcept(const QString &conceptName);
    Q_INVOKABLE void removeConcept(const QString &conceptName);
    Q_INVOKABLE void clearConcepts();
    Q_INVOKABLE void generateImage(const QString &aspectRatio = QStringLiteral("1:1"));
    Q_INVOKABLE void selectImage(const QString &imagePath);
    Q_INVOKABLE void copyToClipboard(const QString &imagePath);
    Q_INVOKABLE void saveToPictures(const QString &imagePath);
    Q_INVOKABLE void liftSubjectSticker(const QString &imagePath);
    Q_INVOKABLE void deleteFromGallery(const QString &imagePath);
    Q_INVOKABLE void openGalleryFolder();
    Q_INVOKABLE void refreshGallery();

Q_SIGNALS:
    void generatingChanged();
    void statusMessageChanged();
    void currentImagePathChanged();
    void currentPromptTextChanged();
    void selectedConceptsChanged();
    void galleryImagesChanged();
    void availableConceptsChanged();
    void imageGenerated(const QString &filePath);

private Q_SLOTS:
    void onDownloadFinished(QNetworkReply *reply);

private:
    void initStorage();
    void loadAvailableConcepts();

    bool m_isGenerating = false;
    QString m_statusMessage;
    QString m_currentImagePath;
    QString m_currentPromptText;
    QStringList m_selectedConcepts;
    QVariantList m_galleryImages;
    QVariantList m_availableConcepts;

    QNetworkAccessManager *m_nam = nullptr;
    QString m_storageDir;
    QString m_cacheDir;
};

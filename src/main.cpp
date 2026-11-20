/*
    SPDX-FileCopyrightText: 2026 Cesar
    SPDX-License-Identifier: GPL-3.0-or-later
*/

#include <QApplication>
#include <QQuickWindow>
#include <QTimer>
#include <QCommandLineParser>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <KAboutData>
#include <KLocalizedString>

#include "playgroundcontroller.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QCommandLineParser parser;
    parser.setApplicationDescription(QStringLiteral("Estudio de creación visual e ilustración con conceptos para KDE Plasma"));
    parser.addHelpOption();
    parser.addVersionOption();
    QCommandLineOption screenshotOpt(QStringLiteral("screenshot"),
                                     QStringLiteral("Capture window screenshot and exit"),
                                     QStringLiteral("path"));
    parser.addOption(screenshotOpt);
    parser.process(app);

    KLocalizedString::setApplicationDomain(QByteArrayLiteral("kimageplayground"));
    app.setOrganizationName(QStringLiteral("Cesar"));
    app.setOrganizationDomain(QStringLiteral("cesar.org"));
    app.setApplicationName(QStringLiteral("kimageplayground"));
    app.setDesktopFileName(QStringLiteral("org.cesar.kimageplayground"));
    app.setWindowIcon(QIcon::fromTheme(QStringLiteral("org.cesar.kimageplayground"), QIcon::fromTheme(QStringLiteral("draw-brush"))));

    KAboutData aboutData(
        QStringLiteral("kimageplayground"),
        i18n("KImagePlayground"),
        QStringLiteral("0.1.0"),
        i18n("Estudio de creación visual e ilustración con conceptos para KDE Plasma"),
        KAboutLicense::GPL_V3,
        i18n("© 2026 Cesar")
    );
    aboutData.setDesktopFileName(QStringLiteral("org.cesar.kimageplayground"));
    KAboutData::setApplicationData(aboutData);

    PlaygroundController controller;

    QQmlApplicationEngine engine;
    engine.addImportPath(QStringLiteral("/usr/lib/qt6/qml"));
    engine.rootContext()->setContextProperty(QStringLiteral("Playground"), &controller);

    const QUrl url(QStringLiteral("qrc:/qt/qml/org/cesar/kimageplayground/main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl) {
                QCoreApplication::exit(-1);
            }
        },
        Qt::QueuedConnection
    );

    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    if (parser.isSet(screenshotOpt)) {
        if (auto *win = qobject_cast<QQuickWindow *>(engine.rootObjects().constFirst())) {
            const QString outPath = parser.value(screenshotOpt);
            QTimer::singleShot(500, win, [win, outPath, &app]() {
                const QImage img = win->grabWindow();
                img.save(outPath);
                app.quit();
            });
        }
    }

    return app.exec();
}

/*
    SPDX-FileCopyrightText: 2026 Cesar
    SPDX-License-Identifier: GPL-3.0-or-later
*/

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <KAboutData>
#include <KLocalizedString>
#include <KLocalizedContext>

#include "playgroundcontroller.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setOrganizationName(QStringLiteral("Cesar"));
    app.setOrganizationDomain(QStringLiteral("cesar.org"));
    app.setApplicationName(QStringLiteral("kimageplayground"));
    app.setDesktopFileName(QStringLiteral("org.cesar.kimageplayground"));
    app.setWindowIcon(QIcon::fromTheme(QStringLiteral("draw-brush")));

    KAboutData aboutData(
        QStringLiteral("kimageplayground"),
        i18n("KImagePlayground"),
        QStringLiteral("0.1.0"),
        i18n("Estudio de creación visual e ilustración con conceptos para KDE Plasma"),
        KAboutLicense::GPL_V3,
        i18n("© 2026 Cesar")
    );
    KAboutData::setApplicationData(aboutData);

    PlaygroundController controller;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
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

    return app.exec();
}

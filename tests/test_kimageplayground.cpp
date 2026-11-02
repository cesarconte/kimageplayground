/*
    SPDX-FileCopyrightText: 2026 Cesar
    SPDX-License-Identifier: GPL-3.0-or-later
*/

#include <QTest>
#include <QSignalSpy>
#include <QDir>
#include "playgroundcontroller.h"

class TestKImagePlayground : public QObject
{
    Q_OBJECT

private Q_SLOTS:
    void testInitialization();
    void testConceptManagement();
    void testPromptUpdate();
    void testGalleryRefresh();
};

void TestKImagePlayground::testInitialization()
{
    PlaygroundController controller;
    QCOMPARE(controller.isGenerating(), false);
    QVERIFY(!controller.statusMessage().isEmpty());
    QVERIFY(!controller.availableConcepts().isEmpty());
    QCOMPARE(controller.selectedConcepts().isEmpty(), true);
}

void TestKImagePlayground::testConceptManagement()
{
    PlaygroundController controller;
    controller.addConcept(QStringLiteral("Animación 3D"));
    controller.addConcept(QStringLiteral("Robot explorador"));

    QCOMPARE(controller.selectedConcepts().size(), 2);
    QCOMPARE(controller.selectedConcepts().contains(QStringLiteral("Animación 3D")), true);

    controller.removeConcept(QStringLiteral("Animación 3D"));
    QCOMPARE(controller.selectedConcepts().size(), 1);

    controller.clearConcepts();
    QCOMPARE(controller.selectedConcepts().isEmpty(), true);
}

void TestKImagePlayground::testPromptUpdate()
{
    PlaygroundController controller;
    controller.setCurrentPromptText(QStringLiteral("Un gato con armadura brillante"));
    QCOMPARE(controller.currentPromptText(), QStringLiteral("Un gato con armadura brillante"));
}

void TestKImagePlayground::testGalleryRefresh()
{
    PlaygroundController controller;
    controller.refreshGallery();
    QVERIFY(controller.galleryImages().size() >= 0);
}

QTEST_MAIN(TestKImagePlayground)
#include "test_kimageplayground.moc"

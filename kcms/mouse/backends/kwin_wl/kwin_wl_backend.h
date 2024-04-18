/*
    SPDX-FileCopyrightText: 2018 Roman Gilg <subdiff@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#pragma once

#include "inputbackend.h"

#include <QList>

class QDBusInterface;

class KWinWaylandBackend : public InputBackend
{
    Q_OBJECT

    Q_PROPERTY(QVariantMap buttonMapping READ buttonMapping WRITE setButtonMapping NOTIFY buttonMappingChanged)

public:
    explicit KWinWaylandBackend(QObject *parent = nullptr);
    ~KWinWaylandBackend();

    bool applyConfig() override;
    bool getConfig() override;
    bool getDefaultConfig() override;
    bool isSaveNeeded() const override;
    QString errorString() const override;
    int deviceCount() const override;
    QList<QObject *> getDevices() const override;

    QVariantMap buttonMapping();
    void setButtonMapping(const QVariantMap &mapping);

Q_SIGNALS:
    void buttonMappingChanged();

private Q_SLOTS:
    void onDeviceAdded(QString);
    void onDeviceRemoved(QString);

private:
    void findDevices();

    QDBusInterface *m_deviceManager;
    QList<QObject *> m_devices;
    QVariantMap m_buttonMapping;
    QVariantMap m_loadedButtonMapping;

    QString m_errorString = QString();
};

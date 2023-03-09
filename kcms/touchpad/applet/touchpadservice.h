/*
    SPDX-FileCopyrightText: 2013 Alexander Mezin <mezin.alexander@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/
#pragma once

#include <Plasma5Support/Service>

class OrgKdeTouchpadInterface;

class TouchpadService : public Plasma5Support::Service
{
    Q_OBJECT
public:
    TouchpadService(OrgKdeTouchpadInterface *daemon, const QString &destination, QObject *parent = nullptr);
    ~TouchpadService();

protected:
    Plasma5Support::ServiceJob *createJob(const QString &operation, QMap<QString, QVariant> &parameters) override;

private:
    OrgKdeTouchpadInterface *m_daemon;
    QString m_destination;
};

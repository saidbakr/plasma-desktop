/*
 * Copyright (C) 2013 Alexander Mezin <mezin.alexander@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 */

#ifndef KDED_H
#define KDED_H

#include <QVariantList>
#include <QTimer>
#include <QMessageBox>
#include <QtDBus>

#include <KDEDModule>

#include "touchpadbackend.h"
#include "kdedsettings.h"

class TouchpadDisabler : public KDEDModule
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.kde.touchpad")

public:
    TouchpadDisabler(QObject *, const QVariantList &);

Q_SIGNALS:
    Q_SCRIPTABLE void enabledChanged(bool);

public Q_SLOTS:
    Q_SCRIPTABLE Q_NOREPLY void reloadSettings();
    Q_SCRIPTABLE Q_NOREPLY void toggle();
    Q_SCRIPTABLE Q_NOREPLY void safeToggle();
    Q_SCRIPTABLE bool isEnabled() const;
    Q_SCRIPTABLE bool workingTouchpadFound() const;

private Q_SLOTS:
    void keyboardActivityStarted();
    void keyboardActivityFinished();
    void timerElapsed();
    void mousePlugged();
    void updateCurrentState();
    void showNotification();
    void confirmationFinished(int);

private:
    bool isMousePluggedIn();

    TouchpadBackend *m_backend;
    TouchpadDisablerSettings m_settings;
    QTimer m_enableTimer;
    QMessageBox m_confirmation;

    TouchpadBackend::TouchpadState m_currentState, m_oldState, m_oldKbState,
    m_keyboardDisableState;
    bool m_keyboardActivity, m_mouse;

    bool m_startup;
};

#endif // KDED_H

/***************************************************************************
 *   Copyright (C) 2014 by Eike Hein <hein@kde.org>                   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

#ifndef VIEWPROPERTIESMENU_H
#define VIEWPROPERTIESMENU_H

#include "folderplugin_private_export.h"
#include <QObject>
class QAction;
class QActionGroup;
class QMenu;

class FOLDERPLUGIN_TESTS_EXPORT ViewPropertiesMenu : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QObject *menu READ menu CONSTANT)

    Q_PROPERTY(bool showLayoutActions READ showLayoutActions WRITE setShowLayoutActions NOTIFY showLayoutActionsChanged)
    Q_PROPERTY(bool showLockAction READ showLockAction WRITE setShowLockAction NOTIFY showLockActionChanged)
    Q_PROPERTY(bool showIconSizeActions READ showIconSizeActions WRITE setShowIconSizeActions NOTIFY showIconSizeActionsChanged)

    Q_PROPERTY(int arrangement READ arrangement WRITE setArrangement NOTIFY arrangementChanged)
    Q_PROPERTY(int alignment READ alignment WRITE setAlignment NOTIFY alignmentChanged)
    Q_PROPERTY(bool previews READ previews WRITE setPreviews NOTIFY previewsChanged)
    Q_PROPERTY(bool locked READ locked WRITE setLocked NOTIFY lockedChanged)
    Q_PROPERTY(bool lockedEnabled READ lockedEnabled WRITE setLockedEnabled NOTIFY lockedEnabledChanged)
    Q_PROPERTY(int sortMode READ sortMode WRITE setSortMode NOTIFY sortModeChanged)
    Q_PROPERTY(bool sortDesc READ sortDesc WRITE setSortDesc NOTIFY sortDescChanged)
    Q_PROPERTY(bool sortDirsFirst READ sortDirsFirst WRITE setSortDirsFirst NOTIFY sortDirsFirstChanged)
    Q_PROPERTY(int iconSize READ iconSize WRITE setIconSize NOTIFY iconSizeChanged)

public:
    explicit ViewPropertiesMenu(QObject *parent = nullptr);
    ~ViewPropertiesMenu() override;

    QObject *menu() const;

    bool showLayoutActions() const;
    void setShowLayoutActions(bool show);

    bool showLockAction() const;
    void setShowLockAction(bool show);

    bool showIconSizeActions() const;
    void setShowIconSizeActions(bool show);

    int arrangement() const;
    void setArrangement(int arrangement);

    int alignment() const;
    void setAlignment(int alignment);

    bool previews() const;
    void setPreviews(bool previews);

    bool locked() const;
    void setLocked(bool locked);

    bool lockedEnabled() const;
    void setLockedEnabled(bool lockedEnabled);

    int sortMode() const;
    void setSortMode(int sortMode);

    bool sortDesc() const;
    void setSortDesc(bool sortDesc);

    bool sortDirsFirst() const;
    void setSortDirsFirst(bool sortDirsFirst);

    int iconSize() const;
    void setIconSize(int iconSize);

Q_SIGNALS:
    void showLayoutActionsChanged() const;
    void showLockActionChanged() const;
    void showIconSizeActionsChanged();
    void arrangementChanged() const;
    void alignmentChanged() const;
    void previewsChanged() const;
    void lockedChanged() const;
    void lockedEnabledChanged() const;
    void sortModeChanged() const;
    void sortDescChanged() const;
    void sortDirsFirstChanged() const;
    void iconSizeChanged();

private:
    QMenu *m_menu;
    QMenu *m_arrangementMenu;
    QActionGroup *m_arrangement;
    QMenu *m_alignmentMenu;
    QActionGroup *m_alignment;
    QActionGroup *m_sortMode;
    QMenu *m_iconSizeMenu;
    QActionGroup *m_iconSize;
    QAction *m_sortDesc;
    QAction *m_sortDirsFirst;
    QAction *m_previews;
    QAction *m_locked;
};

#endif

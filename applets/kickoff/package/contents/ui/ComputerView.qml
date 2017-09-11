/*
    Copyright (C) 2011  Martin Gräßlin <mgraesslin@kde.org>
    Copyright (C) 2012 Marco Martin <mart@kde.org>
    Copyright (C) 2015  Eike Hein <hein@kde.org>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/
import QtQuick 2.0
import org.kde.plasma.private.kicker 0.1 as Kicker

BaseView {
    objectName: "ComputerView"

    Accessible.role: Accessible.Grouping
    Accessible.name: i18n("Computer")

    model: Kicker.ComputerModel {
        id: computerModel

        appNameFormat: rootModel.appNameFormat

        appletInterface: plasmoid

        favoritesModel: globalFavorites

        Component.onCompleted: {
            systemApplications = plasmoid.configuration.systemApplications;
        }
    }

    Connections {
        target: computerModel

        onSystemApplicationsChanged: {
            plasmoid.configuration.systemApplications = target.systemApplications;
        }
    }

    Connections {
        target: plasmoid.configuration

        onSystemApplicationsChanged: {
            computerModel.systemApplications = plasmoid.configuration.systemApplications;
        }
    }
}

/*
 * Copyright 2019 Kai Uwe Broulik <kde@privat.broulik.de>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.3 as QtControls

import org.kde.kirigami 2.7 as Kirigami
import org.kde.kcm 1.2 as KCM

import org.kde.private.kcms.notifications 1.0 as Private

Kirigami.Page {
    id: sourcesPage
    title: i18n("Application Settings")

    Binding {
        target: kcm.filteredModel
        property: "query"
        value: searchField.text
    }

    RowLayout {
        id: rootRow
        anchors.fill: parent

        ColumnLayout {
            Layout.minimumWidth: Kirigami.Units.gridUnit * 12
            Layout.preferredWidth: Math.round(rootRow.width / 3)

            /*Kirigami.SearchField {
                Layout.fillWidth: true
            }*/
            QtControls.TextField { // FIXME search field
                id: searchField
                Layout.fillWidth: true
                placeholderText: i18n("Search...")
                // TODO autofocus this?

                Shortcut {
                    sequence: StandardKey.Find
                    onActivated: searchField.forceActiveFocus()
                }
            }

            QtControls.ScrollView {
                id: sourcesScroll
                Layout.fillWidth: true
                Layout.fillHeight: true
                activeFocusOnTab: false
                Kirigami.Theme.colorSet: Kirigami.Theme.View
                Kirigami.Theme.inherit: false

                Component.onCompleted: background.visible = true

                ListView {
                    id: sourcesList
                    anchors {
                        fill: parent
                        margins: 2
                        //leftMargin: sourcesScroll.QtControls.ScrollBar.vertical.visible ? 2 :  internal.scrollBarSpace/2 + 2
                    }
                    clip: true
                    activeFocusOnTab: true
                    currentIndex: kcm.filteredModel.currentIndex

                    keyNavigationEnabled: true
                    keyNavigationWraps: true
                    highlightMoveDuration: 0

                    section {
                        criteria: ViewSection.FullString
                        property: "sourceType"
                        delegate: QtControls.ItemDelegate {
                            id: sourceSection
                            width: sourcesList.width
                            text: {
                                switch (Number(section)) {
                                case Private.SourcesModel.ServiceType: return i18n("System Services");
                                case Private.SourcesModel.KNotifyAppType: return i18n("Applications");
                                case Private.SourcesModel.FdoAppType: return i18n("Other Applications");
                                }
                            }

                            // unset "disabled" text color...
                            contentItem: QtControls.Label {
                                text: sourceSection.text
                                // FIXME why does none of this work :(
                                //Kirigami.Theme.colorGroup: Kirigami.Theme.Active
                                //color: Kirigami.Theme.textColor
                                color: rootRow.Kirigami.Theme.textColor
                                elide: Text.ElideRight
                                verticalAlignment: Text.AlignVCenter
                            }
                            enabled: false
                        }
                    }

                    model: kcm.filteredModel

                    delegate: QtControls.ItemDelegate {
                        id: sourceDelegate
                        width: sourcesList.width
                        text: model.display
                        highlighted: ListView.isCurrentItem
                        opacity: model.pendingDeletion ? 0.6 : 1
                        onClicked: {
                            var idx = kcm.filteredModel.makePersistentModelIndex(index, 0);
                            kcm.filteredModel.setCurrentIndex(idx);
                            eventsConfiguration.rootIndex = idx;
                            eventsConfiguration.appData = model
                        }

                        contentItem: RowLayout {
                            Kirigami.Icon {
                                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                                Layout.preferredHeight: Kirigami.Units.iconSizes.small
                                source: model.decoration
                                enabled: !model.pendingDeletion
                            }

                            QtControls.Label {
                                Layout.fillWidth: true
                                text: sourceDelegate.text
                                font: sourceDelegate.font
                                color: sourceDelegate.highlighted || sourceDelegate.checked || (sourceDelegate.pressed && !sourceDelegate.checked && !sourceDelegate.sectionDelegate) ? Kirigami.Theme.highlightedTextColor : (sourceDelegate.enabled ? Kirigami.Theme.textColor : Kirigami.Theme.disabledTextColor)
                                elide: Text.ElideRight
                            }

                            // FIXME alignment
                            QtControls.ToolButton {
                                Layout.preferredWidth: Kirigami.Units.iconSizes.small + leftPadding + rightPadding
                                Layout.preferredHeight: Kirigami.Units.iconSizes.small + topPadding + bottomPadding
                                icon.name: model.pendingDeletion ? "edit-undo" : "edit-delete"
                                visible: model.removable
                                onClicked: model.pendingDeletion = !model.pendingDeletion

                                QtControls.ToolTip {
                                    text: model.pendingDeletion ? i18n("Undo Remove") : i18n("Remove")
                                }
                            }
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: Math.round(rootRow.width / 3 * 2)

            EventsPage {
                id: eventsConfiguration
                anchors.fill: parent
                visible: !!rootIndex
            }

            QtControls.Label {
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    right: parent.right
                    margins: Kirigami.Units.smallSpacing
                }
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: i18n("No application or event matches your search term.")
                visible: sourcesList.count === 0 && searchField.length > 0
            }
        }
    }
}
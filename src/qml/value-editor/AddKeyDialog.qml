import QtQuick 2.3
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.12
import "./../common"
import "./editors/editor.js" as Editor

BetterDialog {
    id: root
    title: qsTranslate("RDM","Add New Key to ") + (request? request.dbIdString: "")
    visible: false
    property var request

    footer: null

    Item {
        anchors.fill: parent
        implicitHeight: 400
        implicitWidth: 600

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 5

            BetterLabel {
                text: qsTranslate("RDM","Key:")
            }
            BetterTextField {
                id: newKeyName
                Layout.fillWidth: true
                objectName: "rdm_add_key_name_field"
                text: request? request.keyName : ''
            }

            BetterLabel {
                text: qsTranslate("RDM","Type:")
            }

            BetterComboBox {
                id: typeSelector
                model: Editor.getSupportedKeyTypes()
                Layout.fillWidth: true
                objectName: "rdm_add_key_type_field"
            }

            Loader {
                id: valueAddEditor
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 300

                asynchronous: true
                source: Editor.getEditorByTypeString(
                            typeSelector.model[typeSelector.currentIndex])

                onLoaded: {
                    item.state = "new"
                    if (item.keyType !== undefined)
                        item.keyType = typeSelector.model[typeSelector.currentIndex]
                    item.initEmpty()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.minimumHeight: 40
                Item {
                    Layout.fillWidth: true
                }
                BetterButton {
                    objectName: "rdm_add_key_save_btn"
                    text: qsTranslate("RDM","Save")

                    onClicked: {
                        if (!valueAddEditor.item)
                            return

                        valueAddEditor.item.validateValue(function (result) {
                            if (!result)
                                return;

                            root.request.keyName = newKeyName.text
                            root.request.keyType = typeSelector.model[typeSelector.currentIndex]
                            root.request.value = valueAddEditor.item.getValue()
                            keyFactory.submitNewKeyRequest(root.request)
                        })
                    }

                    Connections {
                        target: keyFactory

                        function onKeyAdded() {
                            root.request = null
                            valueAddEditor.item.reset()
                            valueAddEditor.item.initEmpty()
                            root.close()
                        }

                        function onError(err) {
                            addError.text = err
                            addError.open()
                        }
                    }

                }

                BetterButton {
                    text: qsTranslate("RDM","Cancel")
                    onClicked: root.close()
                }
            }
            Item {
                Layout.fillWidth: true
            }
        }

        OkDialog {
            id: addError
            title: qsTranslate("RDM","Error")
            text: ""
            visible: false
        }
    }
}

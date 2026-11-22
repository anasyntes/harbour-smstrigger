#include <sailfishapp.h>
#include <QGuiApplication>
#include <QQuickView>

int main(int argc, char *argv[])
{
    QGuiApplication *app = SailfishApp::application(argc, argv);
    app->setApplicationName("harbour-smstrigger");
    app->setOrganizationName("harbour-smstrigger");

    QQuickView *view = SailfishApp::createView();
    view->setSource(SailfishApp::pathTo("qml/harbour-smstrigger.qml"));
    view->show();

    return app->exec();
}

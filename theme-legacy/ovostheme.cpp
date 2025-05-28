#include "ovostheme.h"
#include <QQuickWindow>
#include <QQuickRenderControl>
#include <KConfigGroup>
#include <KSharedConfig>
#include <QStandardPaths>

#include <QScopeGuard>
#include <QPalette>
#include <KIconLoader>

OvosTheme::OvosTheme(QObject *parent)
    : PlatformTheme(parent)
{
    setupFileWatch();
    syncColors();
    setSupportsIconColoring(true);

    auto parentItem = qobject_cast<QQuickItem *>(parent);
    if (parentItem) {
        connect(parentItem, &QQuickItem::enabledChanged, this, &OvosTheme::syncColors);
        connect(parentItem, &QQuickItem::visibleChanged, this, &OvosTheme::syncColors);
        connect(parentItem, &QQuickItem::windowChanged, this, &OvosTheme::syncWindow);
    }
    syncWindow();
}

void OvosTheme::syncColors()
{
    readConfig();
    QColor theme_window = m_primaryColor;
    QColor theme_window_text = m_textColor;
    QColor theme_base = m_primaryColor;
    QColor theme_text = m_textColor;
    QColor theme_button = m_secondaryColor;
    theme_button.setAlphaF(0.8);

    QColor theme_button_text = m_textColor;
    QColor theme_highlight = m_secondaryColor;

    QColor theme_highlight_text = m_secondaryColor.lighter(150);

    QColor theme_tool_tip = m_primaryColor;
    QColor theme_tool_tip_text = m_textColor;

    QColor theme_link = m_secondaryColor;
    theme_link.setAlphaF(0.5);

    QColor theme_link_visited = m_secondaryColor;
    theme_link_visited.setAlphaF(0.3);

    QColor theme_alternate_base = m_primaryColor;
    theme_alternate_base.setAlphaF(0.5);

    QColor theme_disabled_text = m_textColor;
    theme_disabled_text.setAlphaF(0.8);

    for (auto group : {QPalette::Active, QPalette::Inactive, QPalette::Disabled}) {
        lightPalette.setColor(group, QPalette::WindowText, theme_window_text);
        lightPalette.setColor(group, QPalette::Window, theme_window);
        lightPalette.setColor(group, QPalette::Base, theme_base);
        lightPalette.setColor(group, QPalette::Text, theme_text);
        lightPalette.setColor(group, QPalette::Button, theme_button);
        lightPalette.setColor(group, QPalette::ButtonText, theme_button_text);
        lightPalette.setColor(group, QPalette::Highlight, theme_highlight);
        lightPalette.setColor(group, QPalette::HighlightedText, theme_highlight_text);
        lightPalette.setColor(group, QPalette::ToolTipBase, theme_tool_tip);
        lightPalette.setColor(group, QPalette::ToolTipText, theme_tool_tip_text);
        lightPalette.setColor(group, QPalette::Link, theme_link);
        lightPalette.setColor(group, QPalette::LinkVisited, theme_link_visited);
        lightPalette.setColor(group, QPalette::AlternateBase, theme_alternate_base);
        lightPalette.setColor(group, QPalette::BrightText, theme_link);
        lightPalette.setColor(group, QPalette::PlaceholderText, theme_disabled_text);
    }

   setTextColor(lightPalette.color(QPalette::Active, QPalette::WindowText));
   setDisabledTextColor(lightPalette.color(QPalette::Active, QPalette::PlaceholderText));
   setHighlightedTextColor(lightPalette.color(QPalette::Active, QPalette::HighlightedText));
   setActiveTextColor(lightPalette.color(QPalette::Active, QPalette::Text));
   setLinkColor(lightPalette.color(QPalette::Active, QPalette::Link));
   setVisitedLinkColor(lightPalette.color(QPalette::Active, QPalette::LinkVisited));
   setNegativeTextColor(lightPalette.color(QPalette::Active, QPalette::Window));
   setNeutralTextColor(lightPalette.color(QPalette::Active, QPalette::Window).lighter(100));
   setPositiveTextColor(lightPalette.color(QPalette::Active, QPalette::WindowText));

   setBackgroundColor(lightPalette.color(QPalette::Active, QPalette::Window));
   setAlternateBackgroundColor(lightPalette.color(QPalette::Active, QPalette::AlternateBase));
   setHighlightColor(lightPalette.color(QPalette::Active, QPalette::Highlight));
   setActiveBackgroundColor(lightPalette.color(QPalette::Active, QPalette::Window));
   setNegativeBackgroundColor(lightPalette.color(QPalette::Active, QPalette::Text));
   setNeutralBackgroundColor(lightPalette.color(QPalette::Active, QPalette::AlternateBase));
   setPositiveBackgroundColor(lightPalette.color(QPalette::Active, QPalette::Window));

   setLinkBackgroundColor(lightPalette.color(QPalette::Active, QPalette::Window));
   setVisitedLinkBackgroundColor(lightPalette.color(QPalette::Active, QPalette::Window));

   setFocusColor(lightPalette.color(QPalette::Active, QPalette::Highlight));
   setHoverColor(lightPalette.color(QPalette::Active, QPalette::Highlight));
}

void OvosTheme::syncWindow(){
    if (m_window) {
        disconnect(m_window.data(), &QWindow::activeChanged, this, &OvosTheme::syncColors);
    }

    QWindow *window = nullptr;

    auto parentItem = qobject_cast<QQuickItem *>(parent());
    if (parentItem) {
        QQuickWindow *qw = parentItem->window();

        window = QQuickRenderControl::renderWindowFor(qw);
        if (!window) {
            window = qw;
        }
        if (qw) {
            connect(qw, &QQuickWindow::sceneGraphInitialized, this, &OvosTheme::syncWindow);
        }
    }
    m_window = window;

    if (window) {
        connect(m_window.data(), &QWindow::activeChanged, this, &OvosTheme::syncColors);
        syncColors();
    }
}

bool OvosTheme::event(QEvent *event)
{
    if (event->type() == QEvent::ThemeChange) {
        syncColors();
    }
    return PlatformTheme::event(event);
}

void OvosTheme::readConfig()
{
    static KSharedConfigPtr config = KSharedConfig::openConfig(QLatin1String("OvosTheme"));
    static KConfigGroup grp(config, QLatin1String("ColorScheme"));

    if (grp.isValid()) {
           m_themeStyle = grp.readEntry<QString>(QLatin1String("themeStyle"), QLatin1String("dark")); 
           if (m_themeStyle == QLatin1String("dark") || m_themeStyle == QLatin1String("Dark")) {
               m_primaryColor = grp.readEntry(QLatin1String("primaryColor"), "#313131");
               m_textColor = grp.readEntry(QLatin1String("textColor"), "#F1F1F1");
           } else {
               m_primaryColor = grp.readEntry(QLatin1String("textColor"), "#F1F1F1");
               m_textColor = grp.readEntry(QLatin1String("primaryColor"), "#313131");
           }

           m_secondaryColor = grp.readEntry(QLatin1String("secondaryColor"), "#F70D1A");
    } else {
        m_themeStyle = QLatin1String("dark");
        m_primaryColor = "#313131";
        m_secondaryColor = "#F70D1A";
        m_textColor = "#F1F1F1";
    }
}

void OvosTheme::syncConfigChanges()
{
    static KSharedConfigPtr config = KSharedConfig::openConfig(QLatin1String("OvosTheme"));
    static KConfigGroup grp(config, QLatin1String("ColorScheme"));
    config->reparseConfiguration();
    readConfig();
    syncColors();
}

void OvosTheme::setupFileWatch()
{
    m_fileWatcher = new QFileSystemWatcher(this);
    m_fileWatcher->addPath(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) + QStringLiteral("/OvosTheme"));
    m_fileWatcher->addPath(QStringLiteral("/etc/xdg/OvosTheme"));
    connect(m_fileWatcher, &QFileSystemWatcher::fileChanged, this, &OvosTheme::syncConfigChanges);
}


QIcon OvosTheme::iconFromTheme(const QString &name, const QColor &customColor)
{
#ifndef Q_OS_ANDROID
    QPalette pal = palette();
    if (customColor != Qt::transparent) {
        for (auto state : {QPalette::Active, QPalette::Inactive, QPalette::Disabled}) {
            pal.setBrush(state, QPalette::WindowText, customColor);
        }
    }

    QPalette olderPalette = KIconLoader::global()->customPalette();

    auto cleanup = qScopeGuard([&] {
        KIconLoader::global()->setCustomPalette(olderPalette);
    });

    KIconLoader::global()->setCustomPalette(pal);
    return KDE::icon(name, KIconLoader::global());
#else
    // On Android we don't want to use the KIconThemes-based loader since that appears to be broken
    return QIcon::fromTheme(name);
#endif
}

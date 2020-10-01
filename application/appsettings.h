/*
 * Copyright 2019 by Marco Martin <mart@kde.org>
 * Copyright 2018 by Aditya Mehra <aix.m@outlook.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#pragma once

#include <QSettings>
#include <QCoreApplication>
#include <QDebug>

class QSettings;

class AppSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString rotation READ rotation WRITE setRotation NOTIFY rotationChanged)
    Q_PROPERTY(qreal fakeBrightness READ fakeBrightness WRITE setFakeBrightness NOTIFY fakeBrightnessChanged)
    
public:
    explicit AppSettings(QObject *parent = nullptr);

    void setRotation(const QString &rotation);
    QString rotation() const;

    void setFakeBrightness(qreal brightness);
    qreal fakeBrightness() const;

Q_SIGNALS:
    void rotationChanged();
    void fakeBrightnessChanged();

private:
    QSettings m_settings;
};


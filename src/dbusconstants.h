// SPDX-FileCopyrightText: 2022 Open Mobile Platform LLC <community@omp.ru>
// SPDX-License-Identifier: BSD-3-Clause

#ifndef DBUSCONSTANTS_H
#define DBUSCONSTANTS_H

#define TRACKER_SERVICE QStringLiteral("org.freedesktop.Tracker3.Miner.Files")
#define TRACKER_INTERFACE QStringLiteral("org.freedesktop.Tracker3.Endpoint")
#define TRACKER_PATH QStringLiteral("/org/freedesktop/Tracker3/Endpoint")
#define SPARQL_QUERY QStringLiteral(\
        "PREFIX nfo: <http://tracker.api.gnome.org/ontology/v3/nfo#>" \
        "PREFIX nie: <http://tracker.api.gnome.org/ontology/v3/nie#> " \
        "SELECT ?path WHERE { ?u nie:url ?path . FILTER(fn:ends-with(nfo:fileName(?u), '.pdf') || fn:ends-with(nfo:fileName(?u), '.txt'))}")
// . FILTER(fn:ends-with(nfo:fileName(?u), '.pdf') || fn:ends-with(nfo:fileName(?u), '.txt'))

#endif // DBUSCONSTANTS_H

---
title: "Zeitsparen mit Word"
author: Holger Just
date: 2008-01-12 13:17 UTC
lang: :de
tags: Technology
cover: 2008/zeitsparen-mit-word/cover.jpg
cover_license: '[Cover Image](https://unsplash.com/photos/54g6dELPr6k) by [Tim Gouw](https://unsplash.com/@punttim), [CC Zero 1.0](https://unsplash.com/license)'
layout: post
---

Es sind die kleinen Dinge, die einem viel Zeit sparen können. Bei Word geht es (zumindest, wenn man Vorlagen einsetzt) häufig darum, alle Felder mit z.B. Referenzen zu aktualisieren.

READMORE

Leider wird das von Microsoft nicht direkt ermöglicht. Es kann natürlich auch sein, dass ich es nur nicht gefunden habe.

Solange man keine Felder in Kopf- und/oder Fußzeilen einsetzt reicht ja ein klassisches Strg+A gefolgt von F9, was sich aber nur auf den "normalen" Text auswirkt.

Möchte man hingegen wirklich *alle* Felder eines Dokuments aktualisieren, dann kann man das folgende einfache Makro hernehmen. Es ist getestet auf Word XP und 2003.

```vb
Sub AlleFelderAktualisieren()
    '  Update All Fields
    Dim Part As Range
    For Each Part In ActiveDocument.StoryRanges
        Part.Fields.Update
        While Not (Part.NextStoryRange Is Nothing)
            Set Part = Part.NextStoryRange
            Part.Fields.Update
        Wend
    Next

    ' Update Table of Contents
    Dim TOC As TableOfContents
    For Each TOC In ActiveDocument.TablesOfContents
        TOC.Update
    Next
End Sub
```

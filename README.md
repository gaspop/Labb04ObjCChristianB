Labb #4 – Diagram

Skapa en GUI-komponent som kan visa ett stapeldiagram.

G
- Er klass ska ärva av UIView
- Implementera drawRect och rita där diagrammet med hjälp av CoreGraphics
- Det ska gå att konfigurera hur många staplar diagrammet visar samt vilken höjd varje stapel har
- Varje stapel ska ha en liten text som beskriver dess namn (detta ska också gå att ställa in på något vis)

VG
- Diagrammets utseende ska kunna initeras/ändras med hjälp av data som har följande struktur:

@[@{@"name": @"january", 
    @"value": @100},
  @{@"name": @"february", 
    @"value": @80},
  @{@"name": @"mars", 
    @"value": @130}]

- Skalan på diagrammet ska sättas automatisk baserat på den högsta stapeln (så att den når toppen av vyn)
- Staplarnas bredd ska anpassas efter vyns bredd
- Staplarna ska få olika färger utifrån en fördefinierad färgskala (t.ex. varannan ljus / mörk)

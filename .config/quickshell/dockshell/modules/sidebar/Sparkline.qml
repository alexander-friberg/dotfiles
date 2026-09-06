import QtQuick

Canvas {
    id: canvas

    property var values: []
    property real min: 0
    property real max: 100
    property color lineColor: "#ffffff"
    property real thickness: 1

    onValuesChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        const ctx = getContext("2d");
        ctx.reset();
        if (values.length < 2) return;

        const range = (max - min) || 1;
        const stepX = width / (values.length - 1);

        ctx.lineWidth = thickness;
        ctx.strokeStyle = lineColor;
        ctx.lineJoin = "round";
        ctx.lineCap = "round";
        ctx.beginPath();

        for (let i = 0; i < values.length; i++) {
            const clamped = Math.max(min, Math.min(max, values[i]));
            const x = i * stepX;
            const y = height - ((clamped - min) / range) * height;
            if (i === 0) ctx.moveTo(x, y);
            else ctx.lineTo(x, y);
        }

        ctx.stroke();
    }
}

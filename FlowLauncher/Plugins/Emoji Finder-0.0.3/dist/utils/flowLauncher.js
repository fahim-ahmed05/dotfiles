export const FlowLauncher = {
    /**
     * Shows a desktop notification.
     * @param title The notification title.
     * @param subtitle The notification text content.
     */
    showMessage: function (title, subtitle) {
        sendJsonRpcRequest({
            method: 'Flow.Launcher.ShowMsg',
            parameters: [
                title,
                subtitle,
                ''
            ]
        });
    }
};
export function sendJsonRpcRequest(req) {
    console.log(JSON.stringify(req));
}
//# sourceMappingURL=flowLauncher.js.map
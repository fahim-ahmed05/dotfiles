import clipboard from 'clipboardy';
import { FlowLauncher } from '../utils/flowLauncher.js';
export function copy(text) {
    if (text !== undefined) {
        clipboard.writeSync(text);
        FlowLauncher.showMessage(text, 'Copied to clipboard!');
    }
}
//# sourceMappingURL=copy.js.map
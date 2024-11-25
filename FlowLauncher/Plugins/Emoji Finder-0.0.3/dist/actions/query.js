import { find } from '../utils/find.js';
import { sendJsonRpcRequest } from '../utils/flowLauncher.js';
export function query(input) {
    const result = find(input ?? '');
    sendJsonRpcRequest({ result });
}
//# sourceMappingURL=query.js.map
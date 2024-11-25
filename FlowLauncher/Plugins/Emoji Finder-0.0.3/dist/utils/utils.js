// @ts-expect-error The lib does not support ESM.
import emojiUnicode from 'emoji-unicode';
export function matchesKeyword(inputs, keywords) {
    return inputs.every(input => keywords.some(keyword => keyword.includes(input)));
}
export function getIconFileName(emoji) {
    const codes = emojiUnicode(emoji);
    if (typeof codes === 'string') {
        return 'icons\\' + codes.toLowerCase().split(' ').join('-') + '.png';
    }
}
//# sourceMappingURL=utils.js.map
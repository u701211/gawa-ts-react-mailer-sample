/** QRコードを取得します
 * キャンセルされた場合は空文字が返却されます
*/
export const getQRCode = (callback: (code: string) => void) => {
  (window as any).flutter_getQRCode.callback = (result: string | object) => {
    if (typeof result === 'string') {
      callback(result);
    }
    else {
      throw new Error(JSON.stringify(result))
    }
  };
  (window as any).flutter_getQRCode.postMessage('');
}

export default getQRCode

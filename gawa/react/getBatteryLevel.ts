/** バッテリーレベルを取得します */
export const getBatteryLevel = (callback: (level: number) => void) => {
  (window as any).flutter_getBatteryLevel.callback = (result: number | object) => {
    if (typeof result === 'number') {
      callback(result);
    }
    else {
      throw new Error(JSON.stringify(result))
    }
  };
  (window as any).flutter_getBatteryLevel.postMessage('');
}

export default getBatteryLevel

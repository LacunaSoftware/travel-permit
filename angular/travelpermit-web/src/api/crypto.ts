import { segmentSeparator } from "./constants";

export const hashAlg: EcdsaParams = {
	hash: 'SHA-256',
	name: 'ECDSA'
};

export const keyOps : KeyUsage[] = ['verify'];

export const jwk: JsonWebKey = {
	crv: 'P-256',
	kty: 'EC',
	x: 'e7yZX1L9JolR7zIaA2I_QIEdnj2C8jy3DKpSILqoD4o',
	y: 'IbGzOdj4ikD81oQHgmT7ohHxj8KfZ7M5y45cHryuBzg',
	ext: true,
	key_ops: keyOps
};

export const sigAlg : EcKeyImportParams = { 
	name: 'ECDSA', 
	namedCurve: 'P-256' 
};


export class CryptoHelper {

	static verifyTPSignature (signatureHex: string, segments: string[]) : Promise<boolean> {
		return new Promise(
			(resolve, reject) => {
				const handleError = (err) => {
					console.log("Error while validating signature", err);
					reject(err);
				}
	
				crypto.subtle.importKey('jwk', jwk, sigAlg, false, keyOps)
				.then(key => {
					const tbsData = this.getTbsData(segments);
					const signature = this.decodeAsn1Signature(this.hexToArrayBuffer(signatureHex));
		
					crypto.subtle.verify(hashAlg, key, signature, tbsData).then(verified => {
						resolve(verified);
					}).catch(handleError);
				}).catch(handleError);
			}
		)
	}
	
	private static hexToArrayBuffer(hex: string) {
		var typedArray = new Uint8Array(hex.match(/[\da-f]{2}/gi).map(function (h) {
			return parseInt(h, 16)
		}))
		
		return typedArray;
	}
	
	private static decodeAsn1Signature (array: Uint8Array) {
		let rOffset = 4;
		let rAsn1 = array.slice(rOffset, array[3] + rOffset);
		
		let sOffset = rOffset + rAsn1.length + 2;
		let sAsn1 = array.slice(sOffset, sOffset + array[sOffset-1]);
	
		let r = this.convertToI3EField(rAsn1);
		let s = this.convertToI3EField(sAsn1);
		
		let sig = new Uint8Array(r.length + s.length);
	
		sig.set(r);
		sig.set(s, r.length);
		return sig;
	}
	
	private static convertToI3EField (array: Uint8Array) : Uint8Array {
		const ecFieldLength = 32;
		if (array.length == ecFieldLength) {
			return array
		}
	
		let newArray = new Uint8Array(ecFieldLength);
	
		if (array.length > ecFieldLength) {
			newArray.set(array.slice(array.length - ecFieldLength), 0);
		} else {
			newArray.fill(0, 0, ecFieldLength - array.length);
			newArray.set(array, ecFieldLength - array.length);
		}
	
		return newArray;
	}
	
	
	private static getTbsData(segments: string[]): ArrayBuffer {
		const encoder = new TextEncoder();
		return encoder.encode(segments.slice(0, segments.length - 1).join(segmentSeparator));
	}
}

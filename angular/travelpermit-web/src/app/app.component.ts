import { HttpClient } from '@angular/common/http';
import { Component } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { encode } from 'punycode';
import { latestKnownVersion, magicPrefix, segmentSeparator, spaceMarker } from 'src/api/constants';
import { CryptoHelper, hashAlg, jwk, keyOps, sigAlg } from 'src/api/crypto';
import { BioDocumentType, BioGender, LegalGuardianTypes, TravelPermitTypes } from 'src/api/enums';
import { TravelPermitModel, TravelPermitOfflineModel } from 'src/api/travel-permit';
import { environment } from 'src/environments/environment';
import { DialogAlertComponent } from './dialog-alert/dialog-alert.component';
import { DialogReadCodeComponent } from './dialog-read-code/dialog-read-code.component';
import { DialogReadQrCodeComponent } from './dialog-read-qr-code/dialog-read-qr-code.component';

@Component({
	selector: 'app-root',
	templateUrl: './app.component.html',
	styleUrls: ['./app.component.scss']
})
export class AppComponent {
	offlineData: TravelPermitOfflineModel;
	segments: string[];

	travelPermit: TravelPermitModel;
	loading: boolean = false;

	constructor(
		private dialog: MatDialog,
		private http: HttpClient
	) {

	}

	openQrCodeScanner() {
		const dialogRef = this.dialog.open(DialogReadQrCodeComponent, {
			width: '500px'
		});

		dialogRef.afterClosed().subscribe((r) => {
			if (r) {
				console.log('Read QR Code data', r);
				this.loading = true;
				this.offlineData = null;
				this.travelPermit = null;
				this.parseQrCodeData(r);
			}
		});
	}

	openEnterCode() {
		const dialogRef = this.dialog.open(DialogReadCodeComponent, {
			width: '500px'
		});

		dialogRef.afterClosed().subscribe((r) => {
			if (r) {
				console.log('Read code', r);
				this.loading = true;
				this.offlineData = null;
				this.travelPermit = null;
				this.loadOnlineData(r);
			}
		});
	}

	parseQrCodeData(code: string) {

		const segments = code.split(segmentSeparator);
		if (segments.length == 0 || segments[0] != magicPrefix) {
			this.alert("Este não é um QR Code de Autorização Eletrônica de Viagem");
		}

		const versionStr = segments[1];
		let version = versionStr ? parseInt(versionStr) : null;

		if (!version || version > latestKnownVersion) {
			this.alert("Este não é um QR Code de Autorização Eletrônica de Viagem");
		}

		if (version == 1 && segments.length != 26) {
			this.alert("Houve um problema ao decodificar o QR Code. Por favor tente digitar o código de validação");
		}

		try {
			let index = 2;

			const data: TravelPermitOfflineModel = {
				version: version,
				key: segments[index++],
				expirationDate: this.decodeField(segments[index++]),
				type: this.decodeField(segments[index++]) as TravelPermitTypes,
				requiredGuardian: {
					name: this.decodeField(segments[index++]),
					documentNumber: this.decodeField(segments[index++]),
					documentIssuer: this.decodeField(segments[index++]),
					documentType: this.decodeField(segments[index++]) as BioDocumentType,
					guardianship: this.decodeField(segments[index++]) as LegalGuardianTypes,
				},
				optionalGuardian: {
					name: this.decodeField(segments[index++]),
					documentNumber: this.decodeField(segments[index++]),
					documentIssuer: this.decodeField(segments[index++]),
					documentType: this.decodeField(segments[index++]) as BioDocumentType,
					guardianship: this.decodeField(segments[index++]) as LegalGuardianTypes,
				},
				underage: {
					name: this.decodeField(segments[index++]),
					documentNumber: this.decodeField(segments[index++]),
					documentIssuer: this.decodeField(segments[index++]),
					documentType: this.decodeField(segments[index++]) as BioDocumentType,
					birthDate: this.decodeField(segments[index++]),
					gender: this.decodeField(segments[index++]) as BioGender,
				},
				escort: {
					name: this.decodeField(segments[index++]),
					documentNumber: this.decodeField(segments[index++]),
					documentIssuer: this.decodeField(segments[index++]),
					documentType: this.decodeField(segments[index++]) as BioDocumentType,
				},
				signature: this.decodeField(segments[index++])
			}

			this.segments = segments;
			this.offlineData = data;
			this.verifyOfflineData();
		} catch (ex) {
			this.alert("Houve um problema ao decodificar o QR Code. Por favor tente digitar o código de validação");
			console.log(ex);
		}
	}

	private verifyOfflineData() {
		CryptoHelper.verifyTPSignature(this.offlineData.signature, this.segments)
			.then((v) => {
				if (v) {
					this.loadOnlineData(this.offlineData.key);
				} else {
					this.offlineData = null;
					this.loading = false;
					this.alert('A assinatura do QR code está inválida.');
				}

				
			}).catch(() => {
				this.alert('Ocorreu um erro ao validar a assinatura do QR Code, por favor tente digitar o código presente no documento');
				this.offlineData = null;
				this.loading = false;
			});
	}

	private decodeField(value: string) {
		return value == "" ? null : value.replace(spaceMarker, " ");
	}

	private loadOnlineData(docKey: string) {
		this.loading = true;
		this.http.get<TravelPermitModel>(`${environment.cnbEndpoint}/api/documents/keys/${docKey}/travel-permit`)
			.subscribe((tp) => {
				this.travelPermit = tp;
				console.log('Loaded travel permit', tp);
				this.loading = false;
			}, (err) => {
				this.loading = false;
				console.log('Erro ao obter a autorização de viagem', err);
				this.alert('Ocorreu um erro ao acessar o servidor para obter os dados completos da autorização de viagem. Você terá acesso somente aos dados contidos no QR Code.');
			});
	}

	private alert(message: string, title?: string, useMessageAsHtml?: boolean, disableClose?: boolean): Promise<any> {
		let dialogRef = this.dialog.open(DialogAlertComponent, {
			width: '600px',
			disableClose: disableClose,
			data: {
				message: message,
				title: title,
				useMessageAsHtml: useMessageAsHtml
			}
		});
		
		return dialogRef.afterClosed().toPromise().then(() => {});
	};

	

}

import { Component, OnInit } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { MatIconRegistry } from '@angular/material/icon';
import { DomSanitizer } from '@angular/platform-browser';
import { latestKnownVersion, magicPrefix, segmentSeparator, spaceMarker, version2Segments, version3Segments, version4Segments } from 'src/api/constants';
import { CryptoHelper } from 'src/api/crypto';
import { BioDocumentType, BioGender, DestinationTypes, LegalGuardianTypes, TravelPermitTypes } from 'src/api/enums';
import { JudiciaryTravelPermitModel, TravelPermitModel, TravelPermitOfflineModel } from 'src/api/travel-permit';
import { DialogAlertComponent } from '../dialog-alert/dialog-alert.component';
import { DialogReadCodeComponent } from '../dialog-read-code/dialog-read-code.component';
import { DialogReadQrCodeComponent } from '../dialog-read-qr-code/dialog-read-qr-code.component';
import { DocumentService } from '../services/document.service';

@Component({
	selector: 'app-home',
	templateUrl: './home.component.html',
	styleUrls: ['./home.component.scss']
})
export class HomeComponent implements OnInit {
	travelPermit: TravelPermitModel | TravelPermitOfflineModel;
	judiciaryTravelPermit: JudiciaryTravelPermitModel;
	segments: string[];
	loading: boolean = false;

	readonly VERSION_2_SEGMENTS = 26;
	readonly VERSION_3_SEGMENTS = 27;
	readonly VERSION_4_SEGMENTS = 34;


	constructor(
		private dialog: MatDialog,
		private documentService: DocumentService,
		private matIconRegistry: MatIconRegistry,
		private domSanitizer: DomSanitizer
	) {
		this.matIconRegistry.addSvgIcon('whatsapp', this.domSanitizer.bypassSecurityTrustResourceUrl('assets/img/icons/whatsapp.svg'));
	}

	ngOnInit() { }

	openQrCodeScanner() {
		const dialogRef = this.dialog.open(DialogReadQrCodeComponent, {
			width: '500px'
		});

		dialogRef.afterClosed().subscribe((r) => {
			if (r) {
				console.log('Read QR Code data', r);
				this.loading = true;
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
		const version = versionStr ? parseInt(versionStr) : null;

		if (!version || version > latestKnownVersion || version < 1) {
			this.alert("Este não é um QR Code de Autorização Eletrônica de Viagem");
		}

		if ((version <= 2 && segments.length != version2Segments) ||
			(version == 3 && segments.length != version3Segments) ||
			(version == 4 && segments.length != version4Segments)) {
			this.alert("Houve um problema ao decodificar o QR Code. Por favor tente digitar o código de validação");
		}

		try {
			let index = 2;

			const data: TravelPermitOfflineModel = {
				version: version,
				key: segments[index++],
				startDate: version >= 3 ? this.decodeField(segments[index++]) : null,
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
					guardianship: version >= 4 ? this.decodeField(segments[index++]) as LegalGuardianTypes : null,
				},
				judge: version >= 4 ? {
					name: this.decodeField(segments[index++]),
				} : null,
				organization: version >= 4 ?{
					name: this.decodeField(segments[index++]),
				} : null,
				judge: version >= 4 ? this.decodeField(segments[index++]) : null,
				organization: version >= 4 ? this.decodeField(segments[index++]) : null,
				destinationType: version >= 4 ? this.decodeField(segments[index++]) as DestinationTypes : null,
				country: version >= 4 ? this.decodeField(segments[index++]) : null,
				state: version >= 4 ? this.decodeField(segments[index++]) : null,
				city: version >= 4 ? this.decodeField(segments[index++]) : null,
				signature: this.decodeField(segments[index++]),
			}

			this.segments = segments;
			this.verifyOfflineData(data);
		} catch (ex) {
			this.alert("Houve um problema ao decodificar o QR Code. Por favor tente digitar o código de validação");
			console.log(ex);
		}
	}

	private verifyOfflineData(offlineUnverifiedData: TravelPermitOfflineModel) {
		CryptoHelper.verifyTPSignature(offlineUnverifiedData.signature, this.segments)
			.then((v) => {
				if (v) {
					this.travelPermit = offlineUnverifiedData;
					this.loadOnlineData(this.travelPermit.key);
				} else {
					this.travelPermit = null;
					this.loading = false;
					this.alert('A assinatura do QR code está inválida.');
				}
			}).catch(() => {
				this.alert('Ocorreu um erro ao validar a assinatura do QR Code, por favor tente digitar o código presente no documento');
				this.travelPermit = null;
				this.loading = false;
			});
	}

	private decodeField(value: string) {
		return value == "" ? null : value.replace(spaceMarker, " ");
	}

	private loadOnlineData(docKey: string) {
		this.loading = true;
		this.documentService.getTravelPermitInfo(docKey)
			.subscribe((tp) => {
				if (tp.judiciaryTravelPermit) {
					this.travelPermit = tp.judiciaryTravelPermit;
					this.judiciaryTravelPermit = tp.judiciaryTravelPermit;
				} else {
					this.travelPermit = tp.travelPermit;
				}
				this.travelPermit.key = docKey;
				console.log('Loaded travel permit', tp);
				this.loading = false;
			}, () => {
				this.loading = false;
				this.alert('Ocorreu um erro ao acessar o servidor para obter os dados completos da autorização de viagem. Você terá acesso somente aos dados contidos no QR Code.');
			});
	}

	private alert(message: string, title?: string, useMessageAsHtml?: boolean, disableClose?: boolean): Promise<any> {
		const dialogRef = this.dialog.open(DialogAlertComponent, {
			width: '600px',
			disableClose: disableClose,
			data: {
				message: message,
				title: title,
				useMessageAsHtml: useMessageAsHtml
			}
		});

		return dialogRef.afterClosed().toPromise().then(() => { });
	};
}

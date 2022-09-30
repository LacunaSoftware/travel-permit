import { HttpClient } from '@angular/common/http';
import { AfterViewInit, Component, OnInit } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { MatIconRegistry } from '@angular/material/icon';
import { DomSanitizer } from '@angular/platform-browser';
import { latestKnownVersion, magicPrefix, segmentSeparator, spaceMarker } from 'src/api/constants';
import { CryptoHelper } from 'src/api/crypto';
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
export class AppComponent implements OnInit, AfterViewInit {
	travelPermit: TravelPermitModel | TravelPermitOfflineModel;
	segments: string[];
	loading: boolean = false;

	constructor(
		private dialog: MatDialog,
		private http: HttpClient,
		private matIconRegistry: MatIconRegistry,
		private domSanitizer: DomSanitizer
	) {
		this.matIconRegistry.addSvgIcon('whatsapp', this.domSanitizer.bypassSecurityTrustResourceUrl('assets/img/icons/whatsapp.svg'));
	}

	ngOnInit() { }

	ngAfterViewInit() {
		this.initialize(document, "freshchat-js-sdk");
	}

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
		let version = versionStr ? parseInt(versionStr) : null;

		if (!version || version > latestKnownVersion || version < 1) {
			this.alert("Este não é um QR Code de Autorização Eletrônica de Viagem");
		}

		if (version <= 2 && segments.length != 26) {
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

		return dialogRef.afterClosed().toPromise().then(() => { });
	};

	private initialize(i, t) {
		var e;
		i.getElementById(t)
			? this.initFreshChat()
			: ((e = i.createElement("script")).id = t, e.async = !0, e.src = "https://wchat.freshchat.com/js/widget.js", e.onload = (() => this.initFreshChat()), i.head.appendChild(e))
	}

	private initFreshChat() {
		(window as any).fcWidget.init({
			config: {
				cssNames: {
					widget: "custom_fc_frame"
				}
			},
			token: '',
			host: 'https://wchat.freshchat.com',
			siteId: 'VALIDACAOAEV'
		});
	}
}

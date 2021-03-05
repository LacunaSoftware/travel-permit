import { Component, Inject, OnInit, SecurityContext } from '@angular/core';
import { MAT_DIALOG_DATA } from '@angular/material/dialog';
import { DomSanitizer } from '@angular/platform-browser';

@Component({
	selector: 'app-dialog-alert',
	templateUrl: './dialog-alert.component.html',
	styleUrls: ['./dialog-alert.component.scss']
})
export class DialogAlertComponent implements OnInit {

	title: string;
	message: string | null;
	useMessageAsHtml: boolean;

	constructor(
		@Inject(MAT_DIALOG_DATA) public data: any,
		private domSanitizer: DomSanitizer,
	) {
		this.title = data.title || 'Alerta';
		this.message = data.message;
		this.useMessageAsHtml = data.useMessageAsHtml || false;

		if (this.useMessageAsHtml) {
			this.message = this.domSanitizer.sanitize(SecurityContext.HTML, this.message);
		}
	}

	ngOnInit() {
	}
}

import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup } from '@angular/forms';
import { MatDialogRef } from '@angular/material/dialog';

@Component({
	selector: 'app-dialog-read-qr-code',
	templateUrl: './dialog-read-qr-code.component.html',
	styleUrls: ['./dialog-read-qr-code.component.scss']
})
export class DialogReadQrCodeComponent implements OnInit {


	form: FormGroup;
	loading = false;

	constructor(
		private fb: FormBuilder,
		private dialogRef: MatDialogRef<DialogReadQrCodeComponent>,
	) { }

	ngOnInit(): void {
		this.form = this.fb.group({
			qrCodeData: null,
		});

		this.form.controls.qrCodeData.valueChanges.subscribe((v: string) => {
			if (v) {
				this.loading = true;
				if (v.endsWith('\r\n') || v.endsWith('\n')) {
					this.dialogRef.close(v.replace(/(\r\n|\n|\r)/gm, ''));
				}
			} else {
				this.loading = false;
			}
		});
	}

	onBlur() {
		this.dialogRef.close();
	}
}

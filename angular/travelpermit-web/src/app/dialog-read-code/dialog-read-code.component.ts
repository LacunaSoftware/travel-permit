import { stringify } from '@angular/compiler/src/util';
import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup } from '@angular/forms';
import { MatDialogRef } from '@angular/material/dialog';

@Component({
	selector: 'app-dialog-read-code',
	templateUrl: './dialog-read-code.component.html',
	styleUrls: ['./dialog-read-code.component.scss']
})
export class DialogReadCodeComponent implements OnInit {

	form: FormGroup;

	constructor(
		private fb: FormBuilder,
		private dialogRef: MatDialogRef<DialogReadCodeComponent>,
	) { }

	ngOnInit(): void {
		this.form = this.fb.group({
			code: ''
		});
	}

	submit() {
		this.dialogRef.close(this.form.value.code);
	}
}

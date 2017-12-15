pragma solidity ^0.4.16;


contract Age {

	struct AgeRecord {
		uint256 recordID;
		uint256 age;
		uint256 recordDate;
	}
}




}

<?php namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class Age extends Model {
	protected $fillable = [
		'age',
		'value'
	];
	protected $primaryKey = 'age';
}
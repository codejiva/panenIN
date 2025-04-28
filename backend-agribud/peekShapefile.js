// ini gue buat soalnya bingung mau cek daerahnya gimana jadi kita pake function aja
const shapefile = require('shapefile');
const path = require('path');

async function peekShapefile() {
  const shpPath = path.join(__dirname, './shapefiles/Batas_Kabupaten_BIG_PPBW_V1.shp');
  const dbfPath = path.join(__dirname, './shapefiles/Batas_Kabupaten_BIG_PPBW_V1.dbf');

  const source = await shapefile.open(shpPath, dbfPath);

  while (true) {
    const record = await source.read();
    if (record.done) break;
    console.log(record.value.properties); // Nampilin semua properties
  }
}

peekShapefile().catch(console.error);

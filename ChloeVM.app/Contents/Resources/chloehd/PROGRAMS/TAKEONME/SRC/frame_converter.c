/*
    Frame reader and converter for the BAD APPLE 2 movie rendition for
    the ZX-UNO.
    (C)2018 Miguel Angel Rodriguez Jodar. ZX Projects. ZX-UNO Team.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <stdio.h>
#include <stdlib.h>
//#include <mem.h>

#define KEY_FRAME      0
#define DELTA_FRAME    1
#define END_FRAME      255
#define PIXELES_BORDE  892

#define AUDIO_FILE "takeonme_15350.wav"
#define FRAME_FILENAME "tom%04.4d.bmp"
#define OUTPUT_FILE "TOM.MVZ"

unsigned char bfa1[6144], bfn1[6144];  // storage for current and next frame for screen page 5
unsigned char bfa2[6144], bfn2[6144];  // storage for current and next frame for screen page 7
unsigned char bsound[512];  // 40ms of sound at 12820 Hz
int borderactual = 0;       // current border colour that go with the current frame

int procesa (unsigned short mask, unsigned char *oldframe, unsigned char *newframe, FILE *fs, FILE *fo);
void keyframe (unsigned char *img, FILE *f);
int border (unsigned char *img);
int cuentabits1 (unsigned char byte);

int main()
{
    FILE *ff,*fs,*fo;
    int ifile;
    char nombre[256];
    int frsiz;

    memset (bfa1, 0, sizeof bfa1);
    memset (bfa2, 0, sizeof bfa2);
    ifile=0;

    // PCM audio, 8-bit, unsigned, 12820 Hz
    fs = fopen (AUDIO_FILE, "rb");
    if (!fs)
    {
        fprintf (stderr, "ERROR. Sound file not found\n");
        return 0;
    }
    fseek (fs, 44, SEEK_SET);  // skip the WAV header part

    fo = fopen (OUTPUT_FILE, "wb");  // file to store our movie into.

    while(1)
    {
        // this composes file names baXXXX.bmp for reading
        // uncompressed frames got from VirtualDub
        sprintf (nombre, FRAME_FILENAME, ifile);

        // bitmap files must be 1bit per pixel, vertical mirrored
        // bit 0 = black, bit 1 = white. 256x192 pixels.
        // You can use Irfanview to batch convert images to this format
        ff = fopen (nombre, "rb");
        if (!ff)   // no more files? end of movie file
            break;
        fseek (ff, 62, SEEK_SET);  // skip the BITMAPINFOHEADER structure
        fread (bfn1, 6144, 1, ff); // and read the actual picture
        fclose (ff);

        // process this frame for memory page 5 (which is also at 0x4000)
        frsiz = procesa (0x4000, bfa1, bfn1, fs, fo);
        ifile++;

        // Do the same as above for page 7 (0xC000 once it is paged in)
        sprintf (nombre, FRAME_FILENAME, ifile);
        ff = fopen (nombre, "rb");
        if (!ff)
            break;
        fseek (ff, 62, SEEK_SET);
        fread (bfn2, 6144, 1, ff);
        fclose (ff);

        frsiz = procesa (0xC000, bfa2, bfn2, fs, fo);
        ifile++;

        // some feedback for the user...
        if ((frsiz%10)== 0) printf ("Processed frame %04.4d (%d)...        \r", ifile, frsiz);
    }
    printf ("Processed frame %04.4d (%d)...        \r", ifile-1, frsiz);

    memset (bsound, 0x80, 512);     // fill last audio block with 0x80 (silence)
    fwrite (bsound, 512, 1, fo);

    memset (bsound, END_FRAME, 4);        // mark end of video (4 bytes with value 0xFF)
    fwrite (bsound, 4, 1, fo);

    fclose (fs);
    fclose (fo);
}

int procesa (unsigned short mask, unsigned char *oldframe, unsigned char *newframe, FILE *fs, FILE *fo)
{
    unsigned char *bcomp = NULL;  // memory block to store the compressed frame
    int icomp = 0;
    int sizebcomp = 0;
    int row,col,scan;
    unsigned short addr;
    int pixelblanco;

    // Add 40ms of sound (512 8-bit samples at 12820 Hz)
    memset (bsound, 0x80, 512);
    fread (bsound, 512, 1, fs);
    fwrite (bsound, 512, 1, fo);

    sizebcomp += 4;
    icomp += 4;
    bcomp = realloc (bcomp, sizebcomp);  // initial allocation of 4 bytes

    // get number of white pixels at the edge of the frame
    pixelblanco = border (newframe);
    // if there is more than 60% white pixels, change border to white (7)
    if (borderactual == 0 && pixelblanco >= (PIXELES_BORDE*6/10))
        borderactual = 7;
    // else if there is less than 40% white pixels, change border to black (0)
    else if (borderactual == 7 && pixelblanco <= (PIXELES_BORDE*4/10))
        borderactual = 0;

    bcomp[1] = borderactual; // store border value at offset 1 of compressed frame
    // offset 0 will indicate the type of frame:
    //  0x00 = KEY FRAME (complete frame, 6144 bytes)
    //  0x01 = DELTA_FRAME (only changes from previous frame (in the same page) are stored
    //  0xFF = END_FRAME. No further info. Just 4 bytes with this value

    // Scan the image using 8x8 pixel blocks (characters in the Spectrum)
    // and for each character, compare it against the same character in the
    // previous frame. If there is a difference, store the complete character
    for (row=0;row<24;row++)
    {
        for (col=0;col<32;col++)
        {
            for (scan=0;scan<8;scan++)
            {
                if (newframe[(row*8+scan)*32+col] != oldframe[(row*8+scan)*32+col])
                    break;
            }
            if (scan<8) // if there was a difference, store the new character
            {
                sizebcomp += 10;
                bcomp = realloc (bcomp, sizebcomp);
                addr = mask + (row/8)*2048 + 32*(row%8) + col; // address in the Spectrum screen of this character
                bcomp[icomp++] = addr&0xFF;        // store it
                bcomp[icomp++] = (addr>>8)&0xFF;
                for (scan=0;scan<8;scan++)  // store the eight scan lines for this character
                {
                    bcomp[icomp++] = newframe[(row*8+scan)*32+col];
                }
            }
        }
    }
    memcpy (oldframe, newframe, 6144); // make old frame to be this current frame
    bcomp[2] = (sizebcomp-4)&0xFF;     // offsets 2 and 3 store the length of the compressed frame
    bcomp[3] = ((sizebcomp-4)>>8)&0xFF;

    if (sizebcomp > 5632)  // if the compressed frame exceeds a certain threshold...
    {
        bcomp[0] = KEY_FRAME;  // then there is no point to store it compressed, instead...
        bcomp[2] = 0x00;       // store it as a KEY FRAME, and update length to be 6144 bytes
        bcomp[3] = 0x18; // 1800h bytes = 6144 bytes

        fwrite (bcomp, 4, 1, fo); // store info for this key frame
        keyframe (newframe, fo);  // and then store the actual frame in Spectrum format
    }
    else
    {
        bcomp[0] = DELTA_FRAME; // mark this frame as delta frame
        fwrite (bcomp, sizebcomp, 1, fo); // and store it
        if (((sizebcomp-4)%10)!=0) printf ("Ouch!!\n");  // DEBUG only: (sizebcomp-4) should be divisible by 10
    }
    free (bcomp);

    return sizebcomp;
}

// store 6144 bytes that make up a linear bitmap file in Spectrum format
void keyframe (unsigned char *img, FILE *f)
{
    int scan, addr;

    for (scan=0;scan<192;scan++)
    {
        addr = (scan/64)*2048+(scan%8)*256+((scan/8)%8)*32;
        fwrite (img+addr, 32, 1, f);
    }
}

// Gets how many 1-bits there is in a byte
int cuentabits1 (unsigned char byte)
{
    int b, cont=0;
    for (b=0;b<8;b++)
    {
        if (byte&1)
            cont++;
        byte = byte>>1;
    }
    return cont;
}

// Counts how many white pixels there are at the edge of the image
int border (unsigned char *img)
{
    int cont=0;
    int i;

    for (i=0;i<32;i++)
    {
        cont += cuentabits1 (img[i]);
        cont += cuentabits1 (img[191*32+i]);
    }
    for (i=1;i<=191;i++)
    {
        if (img[i*32]&0x80)
            cont++;
        if (img[i*32+31]&1)
            cont++;
    }
    return cont;
}